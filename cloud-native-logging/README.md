# Tutorial: EC2 Security Log Collection the Cloud-Native Way

How to utilize modern logging and Serverless technology to jump start your security logging pipeline.

*Check out the article on [our blog](https://blog.runpanther.io/cloud-native-security-log-collection/)*

To detect and prevent security breaches, security teams must understand everything that is happening in the environment. The primary way to accomplish this is by collecting and analyzing log events, which provide information on activity within a system.

Traditionally, this was done with the built-in Unix command-line utility syslog, where data was sent to a set of aggregation points for storage, searching, and analysis. 

However, collecting high value security logs from a large fleet of machines can be a challenge. Luckily, there are new tools to help. Over the years, new projects emerged for performant and flexible log management, such as:

* syslog-ng
* rsyslog
* fluentd (and fluent-bit)
* logstash (and beats)

In this tutorial, we will walk through how to aggregate and store security logs the cloud-native way. We will use Fluentd to transport syslog data from AWS EC2 instances to Amazon S3 in a secure and performant manner. Syslog provides information on users connecting to systems, running sudo commands, installing applications, and more.

---

## Getting Started
Make sure to have the following setup:
* [aws-cli](https://docs.aws.amazon.com/en_pv/cli/latest/userguide/cli-chap-install.html)
* `$ git clone git@github.com:panther-labs/tutorials.git && cd tutorials`

You will use the AWS CLI to run CloudFormation from the Panther Labs tutorials repository with predefined templates.

---

## Step 1: Setup S3 Bucket, Instance Profile, and IAM Role

To centralize data from EC2, we will use a S3 Bucket and an [IAM Instance Profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html) to permit EC2 to send the data to the bucket. Instance profiles allow for temporary credentials to be generated, which avoids usage of long-lived credentials.

Run the command below from the panther-labs/tutorials directory to setup all the required infrastructure above:

```
$ make deploy \
    tutorial=cloud-native-logging \
    stack=security-logging-infra \
    region=us-east-1 \
    parameters="--parameter-overrides OrgPrefix=<PrefixGoesHere>"
```

This will create the following:
* S3 Data Bucket
* Write-only IAM Role to send data to S3
* An IAM Role to allow EC2 to assume the write-only Role
* IAM Instance Profile to attach to the instance

---

## Step 2: Launch EC2 Instance and Configure Fluentd

Next, [launch an Ubuntu instance](https://console.aws.amazon.com/ec2/home?region=us-east-1#LaunchInstanceWizard:) with IAM Role created above. After a couple of moments, the instance will change to the running status in the [EC2 Console](https://console.aws.amazon.com/ec2/home?region=us-east-1#Instances:sort=instanceId).

Connect to the instance with SSH: `$ ssh ubuntu@<public-dns-name> -i <path/to/keypair>`

[Follow the guide](https://docs.fluentd.org/installation/install-by-deb#step-1-install-from-apt-repository) to install Fluentd. 

Use the following Fluentd configuration (`/etc/td-agent/td-agent.conf`) to consume syslog messages from localhost to send to S3:

```
<source>
  @type syslog
  port 5140
  bind 0.0.0.0
  tag system
</source>
<match system.**>
  @type s3
<assume_role_credentials>
    duration_seconds 3600
    role_arn arn:aws:iam::<YOUR-AWS-ACCOUNT-ID>:role/<YOUR-ORG-PREFIX>S3WriteSecurityData
    role_session_name "#{Socket.gethostname}"
  </assume_role_credentials>
s3_bucket <YOUR-AWS-ACCOUNT-ID>-security-data-us-<YOUR-REGION>
  s3_region <YOUR-REGION>
path syslog/
  store_as gzip
<format>
    @type json
  </format>
<buffer tag,time>
    @type file
    path /var/log/td-agent/buffer/s3
    timekey 3600 # 1 hour partition
    timekey_wait 60m
    timekey_use_utc true # use utc
    chunk_limit_size 256m
  </buffer>
</match>
```

Next, configure rsyslog to forward messages to the local Fluentd daemon by adding these two lines to the bottom of `/etc/rsyslog.d/50-default.conf`:

```
# Send log messages to Fluentd
*.* @127.0.0.1:5140
```

To enable this logging pipeline, start both services below:

```
$ sudo systemctl start td-agent.service
$ sudo systemctl restart rsyslog.service
```

To verify the Fluentd (td-agent) service is properly running:

```
$ sudo systemctl status td-agent.service
● td-agent.service - td-agent: Fluentd based data collector for Treasure Data
   Loaded: loaded (/lib/systemd/system/td-agent.service; disabled; vendor preset: enabled)
   Active: active (running) since Tue 2019-12-03 16:47:04 UTC; 27min ago
...
$ sudo tail -f /var/log/td-agent/td-agent.log
2019-12-03 16:54:30 +0000 [info]: gem 'fluent-plugin-s3' version '1.2.0'
2019-12-03 16:54:30 +0000 [info]: gem 'fluent-plugin-td' version '1.0.0'
2019-12-03 16:54:30 +0000 [info]: gem 'fluent-plugin-td-monitoring' version '0.2.4'
2019-12-03 16:54:30 +0000 [info]: gem 'fluent-plugin-webhdfs' version '1.2.4'
2019-12-03 16:54:30 +0000 [info]: gem 'fluentd' version '1.7.4'
2019-12-03 16:54:30 +0000 [info]: adding match pattern="system.**" type="s3"
2019-12-03 16:54:30 +0000 [info]: adding source type="syslog"
2019-12-03 16:54:30 +0000 [info]: #0 starting fluentd worker pid=3272 ppid=1388 worker=0
2019-12-03 16:54:30 +0000 [info]: #0 listening syslog socket on 0.0.0.0:5140 with udp
2019-12-03 16:54:30 +0000 [info]: #0 fluentd worker is now running worker=0
If the service is unable to load or is throwing errors, verify the following:
The /etc/td-agent/td-agent.conf has no syntax errors
The IAM Role is properly attached to the instance
```

If no errors are present, continue onward!

---

## Step 3: View Logs in S3
After about an hour of data is generated, you should see data landing in your S3 Bucket:

```
Each file will have the following format:
{"host":"ip-172-31-92-150","ident":"systemd-timesyncd","pid":"538","message":"Network configuration changed, trying to establish connection."}
{"host":"ip-172-31-92-150","ident":"systemd-timesyncd","pid":"538","message":"Synchronized to time server 91.189.94.4:123 (ntp.ubuntu.com)."}
{"host":"ip-172-31-92-150","ident":"CRON","pid":"32611","message":"(root) CMD (   cd / && run-parts --report /etc/cron.hourly)"}
{"host":"ip-172-31-92-150","ident":"systemd-timesyncd","pid":"538","message":"Network configuration changed, trying to establish connection."}
{"host":"ip-172-31-92-150","ident":"systemd-timesyncd","pid":"538","message":"Synchronized to time server 91.189.94.4:123 (ntp.ubuntu.com)."}
```

To search through files, you can use S3 Select with the following settings:
S3 Select File SettingsAnd then issue a SQL query to look for sshd events:

S3 Select Query and Result
If you are reading this, everything is working and you made it to the end!

---

## Summary
This tutorial taught you how to configure secure and performant security log collection with Fluentd to send directly to a S3 Bucket. This is a jump-off point to more sophisticated collection and analysis of your choosing. 

These concepts can be reused to collect other logs from hosts such as osquery, ossec, and more!
