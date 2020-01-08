# AWS Security Logging Fundamentals - CloudTrail

*A deep dive into AWS CloudTrail - Check out the article on [our blog](https://blog.runpanther.io/aws-cloudtrail-fundamentals/)*

Amazon Web Services offers many services, from virtual machines (EC2) to storage (S3) to databases (RDS). Each of these services adds a new point of entry for potential cyber-attacks. To stay vigilant, security teams must keep a close watch on all activity and changes in AWS accounts.

In this article, we will walk through how to collect high-value security log data with CloudTrail, and discuss the various options available to get the most out of this service.

# CloudTrail Key Benefits
Before we get started with implementation, let's take a quick look at why CloudTrail could be the perfect Swiss Army knife to effectively analyze events that occur in your environment:
* Take Charge of Security Visibility: By using CloudTrail, you will be able to discover and analyze every single activity (user, role, service, and even API) that occurs within your environment. CloudTrail enables the user discover and troubleshoot operational and security issues and capture a detailed history of changes at regular intervals.
* Easy Compliance and Monitoring: By integrating CloudTrail with another AWS service, such as Amazon CloudWatch, you can alert and expedite your response to any non-compliance event.
* Automate Security: CloudTrail helps to automate responses to security threats faster and enables you to build strong mechanisms to mitigate future threats.
* Detect Data Exfiltration: You can take advantage of CloudTrail to record S3 object-level API events to help with detecting data exfiltration and performing usage analysis of S3 objects.

# Getting Started
Before we begin, let's make sure to have the following pre-requisites in place:
* Install the AWS CLI
* Clone the `panther-labs/tutorials` repository

These tools will enable you to configure best-practice CloudTrail infrastructure with predefined CloudFormation templates.

# Introducing CloudTrail

AWS CloudTrail is a service to audit all activity within your AWS account.
Enabling CloudTrail is critical for understanding the history of account changes and detecting suspicious activity.
Let's try to dig deeper with an example event:

```javascript
{
    "eventVersion": "1.05",
    "userIdentity": {
        "type": "AWSService",
        "invokedBy": "ec2.amazonaws.com"
    },
    "eventTime": "2019-12-10T01:44:26Z",
    "eventSource": "sts.amazonaws.com",
    "eventName": "AssumeRole",
    "awsRegion": "us-east-1",
    "sourceIPAddress": "ec2.amazonaws.com",
    "userAgent": "ec2.amazonaws.com",
    "requestParameters": {
        "roleSessionName": "i-00888ddddd3333322",
        "roleArn": "arn:aws:iam::123456789012:role/S3SecurityDataAssumeRole"
    },
    "responseElements": {
        "credentials": {
            "sessionToken": "IQoJb3JpZ2luX2VjEIL//==",
            "accessKeyId": "AAAASSSRRRRRZZZZZZCC",
            "expiration": "Dec 10, 2019 7:46:42 AM"
        }
    },
    "requestID": "09a32e7f-f51d-4f84-8f53-38e1cd773e3f",
    "eventID": "f12888b4-4208-4ead-aa6a-1a21ffb24c15",
    "resources": [
        {
            "ARN": "arn:aws:iam::123456789012:role/S3SecurityDataAssumeRole",
            "accountId": "123456789012",
            "type": "AWS::IAM::Role"
        }
    ],
    "eventType": "AwsApiCall",
    "recipientAccountId": "123456789012",
    "sharedEventID": "0aa168dc-6402-4bbf-9bc6-4d2bf58f106c"
}
```

Here is what we can extract from the message:
* The `ec2` service made the `AssumeRole` call at `2019–12–10T01:44:26Z`
* The region serving the API call is `us-east-1`
* The role being assumed is `arn:aws:iam::123456789012:role/S3SecurityDataAssumeRole` with the session `i-00888ddddd3333322`, indicating the EC2 hostname
* The request was successful, and temporary credentials were returned
* There was no `errorMessage` key, also indicating a successful operation

For a deeper understanding of CloudTrail log fields, you'd find the documentation on Record Contents useful.

# Deep Dive

CloudTrail can capture two main types of events:

* **Control Plane**: Management operations performed on resources. These events apply to all AWS services, and can be configured to capture Read or Write events (e.g., mike created a S3 bucket called `production-secrets`).
* **Data Plane**: Operations performed directly on resources. These types of events are limited to S3 and Lambda specific calls (e.g., jill downloaded a S3 object from `s3://production-secrets/app/secret.txt`).

Before enabling data plane logging, be mindful of the pricing implications. Data plane settings must also be explicitly set, whereas the default operation for CloudTrail is to log events from the control plane.

## Regions and Organizations

CloudTrail can be configured to capture events from either all regions or a single region.

If you use AWS Organizations, an organization-level trail can be configured to automatically capture all events from each member account. Use the following API call to set an existing CloudTrail as your organization-level trail in your "master" account:

```
$ aws cloudtrail update-trail --name <Trail> --is-organization-trail
```

## Monitoring

There are several ways CloudTrail delivers data for security monitoring, and we have highlighted the notable ones below:

**S3 Bucket**

Buckets are required to create a new CloudTrail, and can optionally be configured to send messages to a SNS topic when new data is delivered. This feature can be used to initiate data processing pipelines, and has increased reliability over using S3 event notifications. Data will be delivered between 5 and 15 minutes from the activity occurring.

**CloudWatch Events**

CloudWatch Events provides the capability of analyzing CloudTrail data in real-time. When a CloudTrail is created, data automatically begins sending to CloudWatch Events and can be processed by using Event Rules to forward information to Lambda functions, Kinesis Streams, and more. The downside to this approach is that each region/account must be instrumented to centralize the data, and only write-level events are captured.

**CloudWatch Logs**

CloudTrail can also be sent to a CloudWatch Log group, with the main advantage of processing multi-region data in real-time from a single place. The downside to this approach, however, is cost and flexibility, since only a single subscription filter can be associated with a log group.

**Macie and GuardDuty**

AWS Macie is a service that uses machine learning on S3 data to identify anomalous activity, and similarly, AWS GuardDuty is a broader service that can identify attacker activity (such as reconnaissance) in an account.

Enabling these services can provide quick wins on analyzing CloudTrail data.

## Encryption

The data sent in CloudTrail is sensitive, so it's recommended to protect it with KMS encryption.

When creating the CloudTrail, a KMS Key can be associated by passing in the key ID. Additionally, to allow users or roles to process the data, an appropriate policy must allow `kms:Decrypt` permissions on the key.

## Insights

CloudTrail recently introduced a feature called Insights to help detect higher than normal API call volume on write-based events.

To enable this feature, use the Insights tab on the CloudTrail Console or following command:

```
$ aws cloudtrail put-insight-selectors --trail-name <Trail> --insight-selectors '[{"InsightType": "ApiCallRateInsight"}]'
```

Here is an example Insights event:
```javascript
{
  "eventVersion": "1.07",
  "eventTime": "2019-10-15T21:14:00Z",
  "awsRegion": "us-east-1",
  "eventID": "EXAMPLEc-9eac-4af6-8e07-26a5ae8786a5",
  "eventType": "AwsCloudTrailInsight",
  "recipientAccountId": "123456789012",
  "sharedEventID": "EXAMPLE8-02b2-4e93-9aab-08ed47ea5fd3",
  "insightDetails": {
    "state": "End",
    "eventSource": "autoscaling.amazonaws.com",
    "eventName": "PutLifecycleHook",
    "insightType": "ApiCallRateInsight",
    "insightContext": {
      "statistics": {
        "baseline": {
          "average": 0.0017857143
        },
        "insight": {
          "average": 4
        },
        "insightDuration": 1
      }
    }
  },
  "eventCategory": "Insight"
}
```

The `insightDetails.insightContext.statistics` field shows the calculated baseline and how this set of API calls went above the threshold.

# Setting Up CloudTrail
To set up a CloudTrail, run the following command from the panther-labs/tutorials repository:

```
$ make deploy \
    tutorial=aws-security-logging \
    stack=cloudtrail \
    region=us-east-1 \
    parameters="--parameter-overrides \
      BucketID=<MyBucketName> TrailName=<MyTrailName>"
```

This will create the following:
* A new CloudTrail with KMS encryption
* A KMS key associated with the proper permissions
* A S3 bucket with Server-Side Encryption, object locking, and other best practices

This CloudTrail can also be used as the organization's master trail by issuing the `aws update-trail` command with the `--is-organization-trail` flag set.

## Viewing Events

There are multiple ways to explore CloudTrail events in the AWS Console
CloudTrail Console

In the CloudTrail Dashboard, users have the capability to search the last 90 days of events with basic filtering and time range constraints

## Amazon Athena
To perform more advanced searches of CloudTrail data with a SQL interface, Athena can be used. To setup Athena, follow the steps below:
* Navigate to the CloudTrail Event history page
* Click the Run Advanced queries in Amazon Athena link
* Select the S3 bucket with CloudTrail data
* Create the table.

In the Athena console, you can now run SQL queries.

# Best Practices and Tips
* **Centralize CloudTrail Logging**: Log all accounts into a single S3 Bucket, with the easiest implementation being an organization wide trail.
* **S3 Access Logging**: Enable S3 Access logging and tracking for CloudTrail in order to identify exfiltration.
* **Object Locking**: For highly compliant environments, enable S3 Object Locking on your S3 Bucket to ensure data cannot not deleted.
* **KMS Encryption**: Ensure log files at rest are encrypted with a Customer Managed KMS key to safeguard against unwarranted access.

# Conclusion
In this article, we covered the fundamentals of AWS CloudTrail. This service is critical for understanding your cloud security posture, and provides a wide variety of rich data.

If you enjoyed this article, let us know by following us!

Stay tuned for the next installment in our logging series, where we will cover several other log types such as VPC, S3 Access, RDS, and more.
