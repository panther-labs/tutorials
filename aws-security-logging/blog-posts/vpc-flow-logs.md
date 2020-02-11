# AWS Security Logging Fundamentals - VPC Flow Logs

*A hands-on tutorial to capture network traffic information, detect anomalies, and prevent malicious activity in your AWS VPC*

At Panther, we understand the challenges faced by security engineers, which is why we are bringing tutorials that empower you with actionable security logging techniques and best practices. Before VPC Flow Logs, AWS customers collected network flow logs by installing agents on their EC2 instances which made the process of collecting, storing, and analyzing network flows cumbersome and offered a limited view of network flows. The [launch of AWS Flow Logs](https://aws.amazon.com/about-aws/whats-new/2015/06/aws-launches-amazon-vpc-flow-logs/) in 2015 enabled security teams to gain visibility into the network traffic moving in and out of their virtual infrastructure. However, many organizations still don’t completely leverage VPC Flow Logs which makes it challenging for security teams to capture network traffic information or perform intrusion detection, leading to suspicious activities going undetected.

In this fourth installment of our security logging series, we show you exactly how to maximize network security and detect malicious activities like never before, using VPC Flow Logs.

To receive the next posts in this series via email, subscribe [here](https://runpanther.io/subscribe/).

## What are AWS VPC Flow Logs?

Amazon VPC Flow Logs enable you to capture information about the network traffic moving to and from network interfaces within your VPC. You can use VPC Flow Logs as a centralized, single source of information to monitor different network aspects of your VPC. VPC Flow logging gives security engineers a history of high-level network traffic flows within entire VPCs, subnets, or specific network interfaces (ENIs). This makes VPC Flow Logs a useful source of information for detection teams focused on collecting network instrumentation across large groups of instances.

### Security Groups vs. Network ACL

Before we get started with VPC Flow Logs, let's take a quick refresher of the building blocks of VPC security. The following diagram offers a starting point:

![img](https://lh4.googleusercontent.com/0GGCKBA75HHNRip8bnTfz71bUgx59UfHjAjdkm6xPwvT5al0E7SDu7iRf_-MIkUNNlHDSjj5M4cm70vekQJk0u76JgLsIhbgnXlzivNg-Z7tZNqI6BNyZbo8B0Il3zs8ysOw96HH)

**Security Groups:** Security Groups allow the movement of network traffic in and out of an instance and act as an application-level firewall. When you launch an EC2 instance, you can associate it with one or more security groups that you create.

**Network ACLs:** Network Access Control Lists (ACLs), on the other hand, act as a network-level firewall for associated subnets that control the traffic movement, and not the instance itself.

The following table offers a quick comparison of both:

| **Security Groups**                                          | **Network ACLs**                                             |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Tied to an instance and act as a firewall for that instance  | Tied to a subnet and act as a firewall for that subnet       |
| They are Stateful which means that the return traffic is allowed automatically regardless of any rules | They are Stateless which means that the return traffic should be explicitly allowed by rules |
| Act as the second layer of defense                           | Act as the first layer of defense                            |
| Evaluate rules before deciding whether to allow the traffic  | Evaluate rules in numbered order                             |

To learn more about the essential concepts that make up VPC security, check out the official [AWS documentation page](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Security.html).

## VPC Flow Logs Use-Cases

Let’s begin by reviewing some use cases when analyzing VPC Flow Logs:

- **Monitoring remote logins** by flagging administrative activity such as SSH and RDP. These ports should only be accessible from trusted sources.
- **Building confidence with ACLS** by monitoring traffic flows between trust zones. For example, your database servers can be grouped into a subnet that only has access from your web server subnet.
- **Threat detection** by monitoring for port scanning, network enumeration attempts, and data exfiltration. Flow Logs can also be used to track lateral movement after a compromised host has been identified.
- **Generating network traffic statistics** by examining new threat patterns and generating reports of risky behaviors or non-compliant protocols.
- **Diagnosing and troubleshooting** connectivity issues and network traffic-related problems.

## VPC Flow Logs Metadata

Amazon VPC Flow Logs contain rich network flow metadata and act as a powerful security resource during an investigation. AWS [recently announced](https://aws.amazon.com/blogs/aws/learn-from-your-vpc-flow-logs-with-additional-meta-data/) the addition of several new fields aimed at simplifying scripts and reducing the number of computations needed to extract useful information from machine-generated logs.

Let’s look at the following table to understand the anatomy of a VPC Flow Log entry. Flow log data can be published to Amazon CloudWatch Logs and Amazon S3 for analysis and long-term storage.

These fields are supported for Flow Logs that publish to both CloudWatch Logs and Amazon S3:

| **Field**      | **Metadata Description**                                     |
| -------------- | ------------------------------------------------------------ |
| `version`      | Specifies the VPC Flow Logs version: <br /><br />default format - 2<br />custom format - 3 |
| `account-id`   | The AWS account ID for the Flow Log                          |
| `interface-id` | The ID of the network interface for which the traffic is recorded |
| `srcaddr`      | The source address for incoming traffic, or the IPv4 or IPv6 address of the network interface for outgoing traffic |
| `dstaddr`      | The destination address for outgoing traffic, or the IPv4 or IPv6 address of the network interface for incoming traffic |
| `srcport`      | The source port of the traffic                               |
| `dstport`      | The destination port of the traffic                          |
| `protocol`     | The [IANA](http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml) protocol number of the traffic |
| `packets`      | The number of packets transferred during the flow            |
| `bytes`        | The number of bytes transferred during the flow              |
| `start`        | The time, in Unix seconds, of the start of the flow          |
| `end`          | The time, in Unix seconds, of the end of the flow            |
| `action`       | The action that is associated with the traffic: <br /><br />**ACCEPT**: The recorded traffic was permitted by the security groups or network ACLs <br />**REJECT**: The recorded traffic was not permitted by the security groups or network ACLs |
| `log-status`   | The logging status of the flow log: <br /><br />**OK**: Data is logging normally to the chosen destinations <br />**NODATA**: There was no network traffic to or from the network interface during the capture window <br />**SKIPDATA**: Some flow log records were skipped during the capture window |

The following table represents new fields that were added recently. These fields are supported for Flow Logs that publish only to Amazon S3.

| **Field**     | **Metadata Description**                                     |
| ------------- | ------------------------------------------------------------ |
| `vpc-id`      | This is the ID of the VPC that contains the source ENI       |
| `subnet-id`   | This is the ID of the subnet that contains the source ENI    |
| `instance-id` | The ID of the instance that's associated with the network interface for which the traffic is recorded |
| `tcp-flags`   | Identifies the bitmask for TCP Flags observed within the aggregation period. TCP flags can be used to identify who initiated or terminated the connection. The bitmask value for these TCP flags are: <br /><br />SYN: 2 <br />SYN-ACK: 18 <br />FIN: 1 <br />RST: 4 |
| `type`        | Identifies the type of traffic which can be IPV4, IPV6 or Elastic Fabric Adapter |
| `pkt-srcaddr` | The packet-level IP address of the source                    |
| `pkt-dstaddr` | The packet-level IP address of the destination               |

**Note:** Packet source and destination IP fields are useful in identifying the source resource and the intended target of a connection passing through a network interface attached to NAT Gateway or an AWS Transit Gateway. These fields are typically used in conjunction to distinguish between the IP address of an intermediate layer through which traffic flows.

## Setup

Before we begin, let’s make sure to have the following prerequisites in place:

* Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* Clone the [panther-labs/tutorials](http://github.com/panther-labs/tutorials) repository

## Enabling VPC Flow Logs

VPC Flow logs can be sent to either CloudWatch Logs or an S3 Bucket.

Log groups can be subscribed to a Kinesis Stream for analysis with AWS Lambda. Alternatively, our recommendation is to use Amazon S3, as this provides the easiest method of scalability and log consolidation. In the next section, we show how to create and publish VPC Flow Log data to Amazon S3.

### Creating and Publishing a VPC Flow Log to Amazon S3

To send Flow Log data to Amazon S3, you’d need an existing S3 bucket to specify. To create an S3 bucket to use with Flow Logs, you can visit the [Create a Bucket](https://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html) page on the AWS Documentation.

After you have created and configured your S3 bucket, the next step is to create a VPC Flow Log to send to S3. You can consider any of the following options to do this:

### Using the Management Console

You can use the following steps to create a VPC Flow Log using the console:

1. Go to the **VPC Dashboard** and choose **Your VPCs** in the navigation pane
2. Select the desired VPCs and then go to **Action** | **Create flow log**
3. You should now see a screen similar to the following screenshot:

![img](https://lh5.googleusercontent.com/bup_MziF3Y38C9_S8tuwa8YK8KutUeSCZ21GfOnrvcVpmWXd-47Sm3de1WikZ3PhJZyOF_JINDmAdFWszqG9WW51EfNyRhxmsWbuWhw-2vobLJRF1xdN6l0yz_NpYvYCWore2f07)

4. You will need to specify the type of IP traffic to log under Filter. You should now see the following options:

- Select **All** to log accepted and rejected traffic
- Select **Rejected** to record only rejected traffic
- Or select **Accepted** to record only accepted traffic

5. Now select **Send to an Amazon S3 bucket** for the **Destination** field

6. You will now need to specify the Amazon Resource Name (ARN) or your existing S3 bucket for the **S3 bucket ARN** field. You can also include a subfolder in the bucket ARN, if you’d like. For example, to specify a subfolder named example-logs in a bucket named `example-bucket`, you can use the following ARN:

```
arn:aws:s3:::example-bucket/example-logs/
```

For further information on S3 bucket permissions for Flow Logs, please use [this link.](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-s3.html#flow-logs-s3-permissions)

7. For the **Format** field, you will need to specify a format for the flow log record

- Select **AWS default format** if you’d like to use the default log record format
- Or use the **Custom format**, to create a format of your own

### Using CloudFormation

The command below will create a new flow log for the given VPC ID to S3. This template can be customized according to your needs, such as for monitoring other types of interfaces such as Subnets or specific ENIs.

```
$ make deploy \
    tutorial=aws-security-logging \
    stack=vpc-flow-logs-s3 \
    region=us-east-1 \
    parameters="--parameter-overrides VpcId=<my-vpc-id>"
```

### Using a Command Line Tool

If you’d like to use a command-line tool to create a Flow Log to send to Amazon S3, you can use one of the following commands:

- Using AWS CLI: **[`create-flow-logs`](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-flow-logs.html)**

  ```
  aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids <vpc-id> \
  --traffic-type ALL \
  --log-destination arn:aws:s3::<my-flow-log-bucket> \
  --log-destination-type s3
  ```

- Using AWS Tools for Windows PowerShell: [`New-EC2FlowLogs`](https://docs.aws.amazon.com/powershell/latest/reference/items/New-EC2FlowLogs.html)

- Using Amazon EC2 Query API: [`CreateFlowLogs`](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateFlowLogs.html)

**Note**: You will notice that the log files are compressed by default. If you’re using the Amazon S3 console to open the log files, they will be decompressed automatically and the Flow Log records will be displayed. However, if you download the files, you will need to decompress the files to view the Flow Log records.

In the next section, we show how to create and publish VPC Flow Log data to Amazon CloudWatch.

## Sending VPC Flow Logs to Amazon CloudWatch

### **Using the AWS Console**

You can create an Amazon CloudWatch log group to receive log data from Amazon VPC by following these steps:

1. Sign in to the Management Console, then open **CloudWatch** under **Management & Governance** services
2. Select **Log groups** in the Navigation pane
3. Click on **Create log group** on the **Actions** dropdown
4. Enter a name for your log group and hit **Create log group** as shown in the following screenshot:

![img](https://lh5.googleusercontent.com/ttkBwOpkyQ_dGTUBR1XFH6dpp8NZkdn5xGkZ9rgOzUA8nrVdMUoD7EHvjabaorYLJqlwYb6LVRu8CQnicVH6LhADuM4VoEmb_OJL-bToBAI-AWA6GFgpqVDdOPIgqrQrkDjU9leS)

5. You should now be able to see a message indicating that your log group is created

![img](https://lh3.googleusercontent.com/c58uo6VV4rKCcp9P4m955cvfi_GVa8YtLI9urGaO5gMy2e8NYvgZ84bOa_e2qEGJ2QIRw0hUPt9mQuYO8_s9f9JCnac72al_AEf6v535uMNzhVzRv0xgQK6p10aSv3V81iWWVwFv)

Now, you will need to create a VPC flow log.

## Creating and Publishing a VPC Flow Log to CloudWatch Logs

To create a VPC Flow Log and send to CloudWatch, you can use one of the following options:

### Using the Management Console

Use the following steps to create and send a VPC Flow Log to CloudWatch Logs:

1. Go to **Networking & Content Delivery** on the console and click **VPC**

![img](https://lh4.googleusercontent.com/PAKIcshieV4HxECdjeZol3dPWvrpR6xZ5fiAlRx-wZW0boeSr1-x-CZ9nzTiNEWxKv4DVjtxAUosv9ztI6VUUs5GSxbkoyhe30whcX5HapBCX2jogzRJEab0qHMfl2Kvoyytyolb)

2. In the navigation pane, select the VPC to monitor, then select **Create Flow Log** under the **Actions** dropdown.

3. You will now need to specify a filter. For **Filter**, specify the type of IP traffic data to log. Choose **All** to log accepted and rejected traffic, **Rejected** to record only rejected traffic, or **Accepted** to record only accepted traffic.

4. Under **Destination,** select the **Send to CloudWatch Logs** option. Select the log group you created in the earlier procedure. You can also enter the name of a log group in CloudWatch Logs to which you would want the Flow Logs to be published.

5. Now you will need to set up IAM permissions. Choose **Set Up Permissions** as shown in the following screenshot:

![img](https://lh5.googleusercontent.com/GdFhtJNADSgpstECnYag7AslKoXCHFlGSKUX-wXEK2ICha69-S3CaXYjBbDQsVQvkdzQmfkZ0p6U-AlphNJtWtGq8OQ_cySCwatYAAcrH8q6jIWQm0C5JQSj0OVwgFH7A4WUAdU6)

6. In the window that opens next, select **Create a new IAM Role** for **IAM Role** and assign a name to your role under **Role Name**. Click **Allow** to submit and return to the previous window.

7. Now return to the **Create flow log** window and hit refresh on the **IAM Role** box. You will be able to see the role you created in step 6.

![img](https://lh4.googleusercontent.com/bIs6NHrT2jYixkha_8bjzRqpyRUb_Qsu3IIUGmkb3i3N2gtArbjl0XtG05tmvvhDYC2Vgn3USZDz_JC0s2wBfpKLczBozfgUQIDJ7EslwPw5yb4w9aTVPGD3ClSdJcseOZfd0QkE)

8. Hit **Create** and then close the window.

9. Now go back to the VPC dashboard and click **Your VPCs** and select the checkbox next to your VPC. Go to the **Flow Logs** tab by scrolling down. You should be able to see the flow log that you created by following the steps we discussed earlier. Ensure that it’s status is active.

### Using CloudFormation

The command below will configure VPC Flow Logs to publish to a CloudWatch Log group. Make sure to run the command from the `panther-labs/tutorials` folder that you cloned!

```
$ make deploy \
    tutorial=aws-security-logging \
    stack=vpc-flow-logs-cloudwatch \
    region=us-east-1 \
    parameters="--parameter-overrides VpcId=<my-vpc-id>"
```

### Using a Command Line Tool

If you’d like to use a command-line tool to create a Flow Log to send to Cloudwatch Logs, you can use one of the following commands:

- Using AWS CLI: [`create-flow-logs`](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-flow-logs.html)

  ```
  aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids <vpc-id> \
  --traffic-type ALL \
  --log-group-name TestLogGroup \
  --deliver-logs-permission-arn <role-arn>
  ```

- Using AWS Tools for Windows PowerShell: [`New-EC2FlowLog`](https://docs.aws.amazon.com/powershell/latest/reference/items/New-EC2FlowLogs.html)

- Using Amazon EC2 Query API: [`CreateFlowLogs`](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateFlowLogs.html)

In the next section, we will show how to query and analyze the Flow Log records in your log files using Amazon Athena.

## Analyzing VPC Flow Log Data

As mentioned earlier, Amazon S3 provides the easiest method of scalability and log consolidation. In the following steps, we will configure Amazon Athena to query the data for our given use cases.

### Creating a Table in Athena

To create an Athena table:

1. First, you need to copy and paste the following DDL statement into the Athena console.

   ```
   CREATE EXTERNAL TABLE IF NOT EXISTS vpc_flow_logs (
     version int,
     account string,
     interfaceid string,
     sourceaddress string,
     destinationaddress string,
     sourceport int,
     destinationport int,
     protocol int,
     numpackets int,
     numbytes bigint,
     starttime int,
     endtime int,
     action string,
     logstatus string
   )  
   PARTITIONED BY (dt string)
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ' '
   LOCATION 's3://example_bucket/prefix/AWSLogs/{subscribe_account_id}/vpcflowlogs/{region_code}/'
   TBLPROPERTIES ("skip.header.line.count"="1");
   ```

   

2. Modify the `LOCATION` `'s3://example_bucket/prefix/AWSLogs/{subscribe_account_id}/vpcflowlogs/{region_code}/`' to point to the Amazon S3 bucket that contains your log data.

3. Next, you will have to run the query in the Athena console. Once the query completes, Athena registers the `vpc_flow_logs` table, making the data in it ready for you to issue queries.

4. Post this, you can create partitions to read the data.

We have compiled a list of useful Athena queries that can help with your security requirements:

A typical detection requirement is to be able to monitor SSH and RDP traffic. Typically SSH is used to log into AWS Linux instances and RDP is used for windows. SSH defaults to using port 22 and RDP defaults to port 3389. To see activity on these ports, run the following query:

```
SELECT
*
FROM vpc_flow_logs
WHERE
 sourceport in (22,3389)
 OR
 destinationport IN (22, 3389)
ORDER BY starttime ASC
```

You may also want to monitor the traffic on administrative web app ports. Assuming your application is serving requests from port 443, then the following query will show the top 10 IP addresses by bytes transferred:

```
SELECT
 ip,
 sum(bytes) as total_bytes
FROM (
SELECT
 destinationaddress as ip,
 sum(numbytes) as bytes
FROM vpc_flow_logs
GROUP BY 1

UNION ALL

SELECT
 sourceaddress as ip,
 sum(numbytes) as bytes
FROM vpc_flow_logs
      GROUP BY 1
)
GROUP BY ip
ORDER BY total_bytes DESC
LIMIT 10
```

Once you create Athena tables and start querying data, you can connect them with Amazon QuickSight to create an interactive dashboard for easy visualization. You can also create dashboards based on the metrics to monitor.

## Limitations of VPC Flow Logs

Although VPC Flow Logs provide deep insight into our network traffic, there are some limitations:

- Once a Flow Log is created, you cannot alter its configuration parameters (such as add or remove fields in the Flow Log record). Instead, you’ll have to delete the Flow Log and create a new one with the required configuration. You also cannot tag a Flow Log.
- If you have configurations involving multiple IPs on a single interface, Flow Logs can be a bit of hindrance. This is because network interfaces with multiple IP addresses will have data logged only for the primary IP as the destination address.
- Flow Logs also exclude certain types of traffic such as DHCP requests, Amazon DNS activity, and traffic generated by a Windows instance for Amazon Windows license activation.
- You cannot enable Flow Logs for network interfaces that are in the EC2-Classic platform prior to December 2013 or for VPCs that are peered with your VPC unless the peer VPC is in your account. In such cases, consider migrating to the current AWS format.

You can find the complete list [here](https://docs.amazonaws.cn/en_us/vpc/latest/userguide/flow-logs.html#flow-logs-limitations). Despite these drawbacks, VPC Flow Logs are a powerful weapon to have in a security engineer’s arsenal because it provides efficiency and visibility across your VPC.

## Conclusion and Next Steps

With increasingly complex AWS environments, it's more important than ever before for security teams to have enhanced and sophisticated tools and techniques at their disposal. An unresolved security threat poses a great risk to organizational data and resources. VPC Flow Logs are an essential step in that direction because they ensure better data security in your organization and allow easy detection of suspicious events and help security teams discover and fix problems quickly.

With this tutorial, we offered practical techniques, use-cases, and hands-on instructions to get started with VPC Flow Logs. In the process, we showed you how to create, publish, and send VPC Flow Logs to Amazon S3 and analyze VPC Flow Logs Data using Amazon Athena.

### How Panther Supports VPC Flow Logs

[Panther](https://runpanther.io/) directly supports VPC Flow Logs as a log source for automated log analysis and Historical Search.  By using Panther, you can write Python rules to evaluate individual VPC Flow Logs as they happen in real-time, as shown in the [example here](https://github.com/panther-labs/panther-analysis/tree/master/analysis/rules/vpc_flow_logs). After processing the logs, Panther stores them in S3 in a performant and easy to search manner. This means you can also do wider-ranging SQL queries of VPC Flow Logs over time using Historical Search via AWS Athena.

Check out our [documentation here](https://docs.runpanther.io/log-analysis/supported-logs) to learn more about how Panther supports VPC Flow Logs. 

Thank you for reading! [Subscribe here](https://runpanther.io/subscribe/) to receive a notification whenever we publish a new post.

## References

1. [AWS Official Documentation: VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)