# AWS Security Logging Fundamentals — S3 Bucket Access Logging

*How to instrument S3 buckets and monitor activity
 - Check out the article on [our blog](https://blog.runpanther.io/s3-bucket-access-logging/)*

AWS S3 is an extraordinary and versatile data store that promises great scalability, reliability, and performance. Yet, S3 bucket security continues to be in the news for all the wrong reasons—from the leak involving exposure of 200mn US voters’ preferences in 2017 to the massive data leaks of social media accounts in 2018, and the infamous ‘Leaky Buckets’ episode in 2019 shook some of the largest organizations including Capital One, Verizon, and even defense contractors. It’s almost impossible to not notice that such data leaks over the years are almost always a result of unsecured S3 Buckets.

This article is the second installment of our AWS security logging-focused tutorials to help you monitor S3 buckets with a special emphasis on object level security (read the first one here). You will discover how an in-depth monitoring based approach can go a long way in enhancing your organization’s data access and security efforts. Using practical instructions, we will walk through everything you need to know to configure S3 bucket access logging, along with CloudFormation samples to kick-start the process.

To receive the next posts in this series via email, subscribe here!

# What is S3 access logging and why use it?
S3 bucket access logging captures information on all requests made to a bucket, such as PUT, GET, and DELETE actions. Bucket access logging is a recommended security best practice that can help teams with upholding compliance standards or identifying unauthorized access to your data. In particular, S3 access logs will be one of the first sources required in any data breach investigation as they track data access patterns over your buckets.

# Setup
Before we begin, let’s make sure to have the following prerequisites in place:

* Install the AWS CLI
* Clone the `panther-labs/tutorials` repository

Next, let’s review some terminology:

* **Source Bucket**: The S3 bucket to monitor.
* **Target Bucket**: The S3 bucket that will receive S3 access logs from source buckets.
* **Access Logs**: Information on requests made to your buckets.

S3 bucket access logging is configured on the source bucket by specifying a target bucket and prefix where access logs will be delivered. It’s important to note that target buckets must live in the same region and account as the source buckets.

To create a target bucket from our predefined CloudFormation templates, run the following command from the cloned tutorials folder:

```bash
$ make deploy \
    tutorial=aws-security-logging \
    stack=s3-access-logs-bucket \
    region=us-east-1
```

This will create a new target bucket with the `LogDeliveryWrite` ACL to allow logs to be written from various source buckets.

Next, let’s configure a source bucket to monitor by filling out the information in the `aws-security-logging/access-logging-config.json` file:

```json
{
  "LoggingEnabled": {
    "TargetBucket": "<AccountId>-s3-access-logs-<Region>",
    "TargetPrefix": "<Source-Bucket-Name>/"
  }
}
```

Then, run the following AWS command to enable monitoring:

```bash
$ aws s3api put-bucket-logging \
  --bucket <Source-Bucket-Name> \
  --bucket-logging-status file://logging.json
```

# Log delivery
To validate the logging pipeline is working, list objects in the target bucket with the AWS Console. The server access logging configuration can also be verified in the source bucket’s properties in the AWS Console. In the next sections, we will examine the collected log data.

# Log format
S3 Access log files are written to the bucket with the following format:

`TargetPrefixYYYY-mm-DD-HH-MM-SS-UniqueString`

Where:
* The `TargetPrefix` is what we specified in the `access-logging-config.json` file
* The `YYYY-mm-DD-HH-MM-SS` is the date/time in UTC when the log file was delivered
* And a unique string is appended to ensure files are not overwritten

It’s also important to understand that log files are written on a best-effort basis, meaning on rare occasions the data may never be delivered.

S3 access logs are written with the following space-delimited format:

`79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be test-bucket [31/Dec/2019:02:05:35 +0000] 63.115.34.165 - E63F54061B4D37D3 REST.PUT.OBJECT  test-file.png "PUT /test-file.png?X-Amz-Security-Token=token-here&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20191231T020534Z&X-Amz-SignedHeaders=content-md5%3Bcontent-type%3Bhost%3Bx-amz-acl%3Bx-amz-storage-class&X-Amz-Expires=300&X-Amz-Credential=ASIASWJRT64ZSKVRP62Z%2F20191231%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Signature=XXX HTTP/1.1" 200 - - - 1 - "https://s3.console.aws.amazon.com/s3/buckets/test-bucket/?region=us-west-2&tab=overview" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36" - Ox6nZZWoBZYJ/a/HLXYw2PVp1nXdSmqdp4fV37m/8SC54q7zTdlAYxuFOWYgOeixYT+yPs6prdc= - ECDHE-RSA-AES128-GCM-SHA256 - test-bucket.s3.us-west-2.amazonaws.com TLSv1.2`

The following information can be extracted from this log to understand the nature of the request:
* A new object `test-file.png`
* was `PUT` into `test-bucket`
* successfully (`200`)
* at `31/Dec/2019:02:05:35 +0000`
* from the IP address `63.115.34.165``
* via a `Mac OS X 10.15.2` laptop running Chrome 79

And additional context we can gather from the log includes:
* `79a59df900b949e55d96a1e698fbacedfd6e09d98eacf8f8d5218e7cd47ef2be` is the bucket owner canonical user ID (an identifier for your account).
* The bucket region is `us-west-2`, per the bucket FQDN `test-bucket.s3.us-west-2.amazonaws.com`
* This was an unauthenticated request
* The request ID is `E63F54061B4D37D3`

For a full reference of each field, check out the AWS documentation.

# Querying S3 access logs with AWS Athena
To gain a deeper understanding of S3 access patterns, we can use AWS Athena, which is a service to query data on S3 with SQL. The following tutorial from AWS can be used to quickly set up an Athena table to enable queries on our newly collected S3 access logs. Remember to point the table to the S3 bucket named <AccountId>-s3-access-logs-<Region>.

Once configured, queries can be run such as:

```sql
SELECT DISTINCT requester, COUNT(*) as requester_count
FROM "default"."s3_access_logs"
WHERE requester != '-'
GROUP BY requester
ORDER BY COUNT(*) DESC
```

Other types of helpful queries include:
* Understanding calls to sensitive files in S3
* Erred (4XX) requests
* High traffic requests (by bytes)
* Deleted objects
* Automation interacting with S3 data

Next, we’ll look into an alternative method for understanding S3 access patterns with CloudTrail.

# Capturing S3 Data Events with CloudTrail
AWS CloudTrail is a service to audit all activity within your AWS account. It has the ability to also monitor events such as GetObject, PutObject, and DeleteObject on S3 bucket objects by enabling data event capture.

If you followed our previous tutorial on CloudTrail, then you are ready to go! If not, walk through it to set one up.

To enable data events from the CloudTrail Console, open the trail to edit, and then:

Now, when data is accessed in your bucket by authenticated users, CloudTrail will capture this context. To see the results use AWS Athena with the following sample query:

Additional SQL queries can be run to understand patterns and statistics.

# Server Access Logging vs. Object-Level Logging
Logging is an intrinsic part of any security operation including auditing, monitoring, and so on. That’s no different when working on AWS which offers two ways to log access to S3 buckets: S3 access logging and CloudTrail object-level (data event) logging. In this section, we will help you understand the differences between both, explore their functionalities, and make informed decisions when choosing one over the other.

S3 Server Access Logging
CloudTrail Data Events
Cost
Only pay for S3 storage costs
$0.10 per 100,000 events
Setup
Must create target logging buckets in each region/account, and configure each source bucket to send to them
Can be enabled on all buckets with a single command
Logging
Logs all access to each object in a bucket
Can choose Read or Write access to an entire bucket and filter by Prefix
Data
HTTP-like access logs that provide externally-focused context, which is ideal for monitoring public buckets
Provides rich internal AWS context on the request, which is ideal for monitoring private buckets
Format
A sequence of newline-delimited log records
JSON
Reliability
Best-effort
Service-level uptime agreement

Our recommendation is the following:
1. Enable S3 Server Access Logging for all buckets. This feature is provided for free, and the only cost associated is the storage cost of the logs, which is low. The logs provide high value context that can be used during an investigation, especially if unauthorized data access is of concern.
1. Enable CloudTrail Data Events on sensitive buckets. Due to the cost of enabling Data Events, we would advise that you only enable it on an as-needed basis. This could include buckets with sensitive PII or financial data.

# Conclusion and Next Steps
Monitoring S3 buckets is an essential first step towards ensuring better data security in your organization. Bucket access logging empowers your security teams to identify attempts of malicious activity within your environment, and through this tutorial we learned exactly how to leverage S3 bucket access logging to capture all requests made to a bucket.

The challenges associated with S3 buckets are at a more fundamental level and could be mitigated to a significant degree by applying best practices and using effective monitoring and auditing tools such as CloudTrail. However, part of the problem of why we see so many S3-related data breaches is because it’s just very easy for users to misconfigure buckets and make them publicly accessible.

The threat landscape changes rapidly, and whilst there’s no such thing as a complete tool to fight every suspicious attempt, deploying intelligent solutions can make a significant difference to your organization’s data security efforts. Which is why Panther Labs’ powerful log analysis solution lets you do just that, and much more. Panther empowers you to have real-time insights in your environment and automatic log-analysis without being overwhelmed with security data. Panther’s uniquely designed security solutions equip you with everything you need to stay a step ahead in the battle against data breaches.

Thanks for reading! Subscribe here to receive a notification whenever we publish a new post.
