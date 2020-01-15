# AWS Serverless Application Repository: Lambda and Beyond

Check out this article on [our blog.](https://blog.runpanther.io/serverless-app-repo-intro/)

Serverless computing is a great way to run your applications without the need for provisioning or managing servers. It makes everything simple—write your code, set the compute resources, and invoke it using the serverless platform. Here’s a quick refresher of some of serverless’ key benefits:

- **Faster execution times**: Functions run on top of containerized platforms which results in quick execution times, unlike traditional cloud instances that are slow to boot up.
- **Low costs**: As you are generally billed only for the duration of the function’s execution and the memory consumed during the execution period, serverless technology is fairly cost-effective.
- **Supports many languages:** Serverless technology supports a variety of languages. For example, AWS Lambda supports Java, Go, PowerShell, Node.js, C#, Python, and even Ruby code.
- **Compatibility with Microservices**: As serverless functions really are small code chunks designed with specific purposes in mind, they complement microservices extremely well. This is a big advantage when compared to monolithic applications, which don’t fare well when it comes to performance and scalability.

## AWS Lambda: The Evolution of Compute

When AWS first introduced Lambda at re:Invent in 2014, the idea was to offer a simple Compute service that also addressed a rather peculiar issue with EC2. Although EC2 was (and still is) one of the most popular core AWS services, it never was designed to respond to events such as inserting a record into a DynamoDB table, or processing an object from a S3 bucket, or a simple event triggered by your application. The biggest value proposition of Lambda is that you can use it to execute event-driven code to develop smaller, on-demand apps which eliminates the need for running or managing servers.

When you upload your code to Lambda, it handles everything including scaling, capacity, and provides the infrastructure needed for your code to run. All you need is to select the amount of memory that your function should be allocated. Based on that, the CPU and other resources are assigned to your function. This is also the biggest advantage of using Lambda, because you only pay for the time your code runs so you needn’t pay for any idle time. This is exactly why AWS Lambda’s adoption has exploded over the years — it does everything to ensure your code gets deployed successfully with a promise of high availability, scalability, and a cost-effective model. Lambda was one of the first and most popular implementations of the FaaS ([Function as a Service](https://en.wikipedia.org/wiki/Function_as_a_service)) model, which enables developers to quickly spin up highly scalable data processing pipelines, scheduled jobs, and other common developer workflows. Because of its popularity, other cloud providers have followed suit with their own FaaS offerings including Microsoft’s [Azure Functions](https://azure.microsoft.com/en-in/services/functions/) and Google’s [GCP Cloud Functions](https://cloud.google.com/functions/).

Then, in 2017, to facilitate the consumption, distribution, and deployment of serverless apps, AWS launched the [Serverless Application Repository (SAR)](https://aws.amazon.com/serverless/serverlessrepo/). Previously, source code had to be shared to distribute Lambda functions, but now with SAR, they can simply be installed with the click of a button.

In this tutorial, we will show you how to get started with SAR to supercharge the management of your serverless functions.

# How SAR Works

SAR accelerates the deployment of serverless applications and provides both application publishers (who write and distribute apps) and application consumers (who search and deploy apps) *an easy-to-search repository of serverless applications that can be easily deployed*.

**As an application consumer, you can discover and deploy pre-built applications to fulfill a specific need,** which allows you to quickly assemble serverless architecture in newer, powerful ways. Similarly, as an application provider or publisher, you wouldn’t want your users to rebuild your application from scratch. With SAR, that’s not a problem.

SAR offers an ecosystem that lets you connect with customers and developers globally and publish serverless applications that touch common use cases and support a diverse range of tech domains such as Security, Machine Learning, Chatbots, Big Data, and more.

You can learn more about the features, use cases, and benefits of AWS SAR [here.](https://aws.amazon.com/serverless/serverlessrepo/)


# The AWS Serverless Ecosystem in a Nutshell

AWS Lambda is undoubtedly the backbone of AWS serverless computing, but there are many other [AWS services](https://aws.amazon.com/modern-apps/services/) that support modern app development. Let’s quickly revisit some of these:

- **AWS Step Functions**: An orchestration service that lets you easily coordinate between workflows thereby helping you save time and effort.
- **Amazon Athena**: An interactive query service that allows you to quickly query any type of data stored in S3. 
- **Amazon SQS**: A distributed messaging and queuing service.
- **Amazon Kinesis**: A fully managed, real-time data streaming service that’s fully scalable.
- **Amazon DynamoDB**: A scalable NoSQL database service.
- **Amazon S3**: A highly-available and fault-tolerant object store service.
- **Amazon SNS**: A message notification service also called a publish/subscribe (pub/sub) service designed for microservices and serverless applications.
- **Amazon API Gateway**: A fully managed, highly-scalable service that lets developers create, publish, and manage APIs. Fully supports containerized and serverless apps.

Each of the services above can be packaged into a SAR application, which adds a great deal of flexibility and opportunity on the nature of distributed apps.

# Components of a SAR App

The AWS Serverless Application Repository allows you to build applications and easily publish and share them publicly or privately. Let’s review an application’s primary components:

- **SAM Template**: This file defines all resources that will be created when deploying your application. [SAM](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md) is an extension of CloudFormation, which offers simplified support for defining AWS services such as Lambda Functions, API Gateway, Dynamo tables and more. Although SAR can be authored without SAM, the full range of resources, functions, and various template features offered in CloudFormation are easily available to you when you use SAM. To learn more about SAM, its benefits, and integration capabilities with other AWS services, [use this link.](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html)
- **Application Policy**: SAR applications must grant policies to allow usage of your application. By defining policies you can make private apps that are only available to your team or public apps to share with specific or all AWS accounts.
- **AWS Region**: As a rule of thumb, when you publish an application to the AWS SAR and set it to ‘public’, the service makes your application available in all AWS Regions (currently only supports us-east-1/us-east-2 Regions). However, ‘private’ and ‘privately shared’ applications are only made available to the AWS Region they were built in.

The following diagram illustrates how the different components of a SAR app tie together:
![img](https://lh5.googleusercontent.com/-VR2Uh90ytqszh33XebmsIAc1-951qInFo--5sgkb1wd2Jz-vkaibP0KYa73yUA7SqqJr0bWGQ1FqnmAtfVunv7bJGtPKvOohhQ_P1dDQCRXaXx27PbLmvElqHW6stzL-CQUC_TH)
It should be noted that the AWS Serverless Application Repository makes it extremely simple to deploy new serverless applications. This way developers can get started with Serverless computing in an effortless manner and can search and discover applications by using category keywords (web, mobile, IoT, chatbots) or simply by the name of the application or its publisher.


# Getting Started

Before we begin, please make sure to have the following prerequisites in place:

- Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html) and the[ AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
- Clone the [panther-labs/tutorials](https://github.com/panther-labs/tutorials) repository

You will use the AWS SAM CLI to run CloudFormation from the Panther Labs tutorials repository with predefined templates.

## Step 1: Writing your application

First, define a sample Lambda function that you can use for the purpose of this tutorial. If you have your own application, feel free to use that as well! 

Our example template will use the `AWS::Serverless::Function` resource type to contain a Lambda function that will print “Hello, Panther” into the Lambda Console:

```
AWSTemplateFormatVersion: 2010-09-09
Transform: AWS::Serverless-2016-10-31
Description: A Sample Hello-World SAR Application

Resources:
  Function:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: sample-application
      Description: A sample SAR application
      Handler: index.main
      InlineCode: |
        import os

        def main(event, context):
          name = os.getenv('NAME', event.get('name', 'world'))
          print('Hello, {}!'.format(name))
      Runtime: python3.7
      MemorySize: 128
      Timeout: 10
      Environment:
        Variables:
          NAME: Panther

```

SAM templates are just like any other CloudFormation template, except you can define one or more serverless resource types. SAM currently supports the following six resources:

[AWS::Serverless::Api](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-api.html)

[AWS::Serverless::Application](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-application.html)

[AWS::Serverless::Function](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-function.html)

[AWS::Serverless::HttpApi](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-httpapi.html)

[AWS::Serverless::LayerVersion](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-layerversion.html)

[AWS::Serverless::SimpleTable](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-resource-simpletable.html)

For more information on AWS Serverless Application Model resources, please refer to the page [here.](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#resource-types)

## Step 2: Creating a bucket to upload Lambda source

Next, you will need to create a S3 Bucket to store packaged Lambda code in order to upload to the Serverless Application Repository.

Run the following command from the tutorials folder:

```
​```bash
make deploy \
  stack=lambda-source-bucket \
  tutorial=serverless-app-repository \
  region=us-east-1
​```

```

This bucket has a policy to grant `serverlessrepo.amazonaws.com` GetObject access on anything within the bucket.

## Step 3: Packaging your Lambda function with SAM

The SAM template can be uploaded to S3 with the following commands:

```
mkdir .out/
sam package \
--template-file serverless-app-repository/cloudformation/sample-application.yml \
	--output-template-file .out/sample-application-out.yml \
	--region us-east-1 \
	--s3-bucket <YOUR-ACCOUNT-ID>-lambda-source-us-east-1 \
	--s3-prefix sample-application

```

If custom dependencies (this example is Python-specific) need to be built into the application, add the following command before the SAM package command above:

```
sam build --manifest requirements.txt --use-container
```

This will spin up a Docker container locally, install dependencies, and then generate a template in `.aws-sam/build/template.yaml`.

## Step 4: Creating your application with SAR

The next step is to create our Serverless application in our account. To do this, run the following command:

```
aws serverlessrepo create-application \
	--author sample \
	--description "My awesome sample application" \
	--home-page-url www.my-website.com \
	--name “sample-application” \
	--region “us-east-1” \
	--semantic-version “0.1.0” \
	--template-body file://.out/sample-application-out.yml

```

To list all published applications, run this command:

```
$ aws serverlessrepo list-applications --region us-east-1
{
    "Applications": [
        {
            "ApplicationId": "arn:aws:serverlessrepo:us-east-1:123456789012:applications/sample-application",
            "Author": "sample",
            "CreationTime": "2020-01-01T23:36:23.875Z",
            "Description": "My awesome sample application",
            "HomePageUrl": "www.my-website.com",
            "Labels": [],
            "Name": "sample-application"
        }
    ]
}

```

This application is also viewable from the [Serverless Application Repository Console](https://console.aws.amazon.com/serverlessrepo/home?region=us-east-1#/published-applications) as shown in the following screenshot:

![img](https://lh4.googleusercontent.com/zCn7_5qhWu9erjFsQzJocZA9EN0T4joCKN5vbChoR-LIlDGgkzlbgyUWPgrPkMJrOg1Ph5p8SQkKZZfrY2KxtEALTdl00nHWifWC_3FEx1mZ4VMTI0ffduHX0aIj0YIDZYVAkpSE)

## Step 5: Adding a SAR application policy

By default, your application will remain private until you add permissions to it. When you publish your application, it's initially set to private, which means that it's only available to the AWS account that created it. 

To share your application with others, you must either set it to privately shared (shared only with a specific set of AWS accounts), or publicly shared (shared with everyone). Applications can be shared publicly (only in us-east-1/us-east-2) or can be shared privately with specific account IDs. 

The following command shows how to add an application policy to share your application:

```
aws serverlessrepo put-application-policy \
		--application-id arn:aws:serverlessrepo:us-east-1:<account-id>:applications/sample-application \
		--region us-east-1 \
		--statements Principals=$(accountIDs),Actions=Deploy ; \
```

For a full reference on setting resource-based policies on SAR apps, check out the [AWS Documentation](https://docs.aws.amazon.com/serverlessrepo/latest/devguide/security_iam_resource-based-policy-examples.html). 

# Deploying Public SAR Apps

In this section, we’ll show you how to deploy SAR applications. There are three ways to do this, so let’s review each of them.

## Using the AWS Management Console

This is the recommended option because users can simply navigate to the [Serverless Application Repository](https://us-west-2.console.aws.amazon.com/serverlessrepo/home?region=us-west-2#/available-applications) in the AWS Console to search and select any available application of their choice as shown in the screenshot below. Note how all publicly available applications are visible:

![img](https://lh6.googleusercontent.com/L-e9_N06l1tx0Al5XzTBCYnv1mDpdw-iFPoowrnHmzcwBBETkQPPTix9NaFgtQzHW2l1qPHbY1cU2grNsB4KvD9j7XL5us9EiHwYt-fGTnnFMyWWgCYsN2lupsVfhnD4SQIsQvgH)
## Using CloudFormation

To deploy a SAR application using CloudFormation, use the `AWS::Serverless::Application` resource as demonstrated below:

```
Resources:
  MyApplication:
    Type: AWS::Serverless::Application
    Properties:
      Location:
        ApplicationId: arn:aws:serverlessrepo:us-east-1:012345678901:applications/sample-application
        SemanticVersion: 0.1.0

```

This will install version 0.1.0 of our sample-application.

## Using the AWS CLI

You can also use the AWS CLI to install an application from the AWS Serverless Application Repository. [This page](https://docs.aws.amazon.com/serverlessrepo/latest/devguide/serverlessrepo-how-to-consume.html) has step by step instructions to show how to deploy a SAR application using the AWS CLI.


# Summing Up

Serverless technology is a big step towards achieving faster execution times, cost efficiency, high performance, and scalability. The Serverless Application Repository (SAR) takes that promise to the next level by enhancing the use of serverless towards better development, deployment, and distribution of applications. With this, we have come to the end of this tutorial where we showed how to get started with the Serverless Application Repository (SAR) and create, publish, and install SAR apps. In the next installment of our SAR tutorial series, we'll cover how to work with multiple applications, use custom policies, and more advanced topics.

Thanks for reading! Subscribe [here](https://runpanther.io/subscribe/) to receive a notification whenever we publish a new post.

# Resources

1. [AWS Serverless Application Repository Developer’s Guide](https://docs.aws.amazon.com/serverlessrepo/latest/devguide/what-is-serverlessrepo.html)

2. [AWS Modern Application Development Services](https://aws.amazon.com/modern-apps/services/)

3. [AWS Serverless Application Model Developer’s Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html)
