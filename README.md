# Panther Labs Tutorials

| Blog        | Code           
| ------------- |:-------------:|
| [Securing Multi-Account Access on AWS](https://blog.runpanther.io/secure-multi-account-aws-access/)      | [aws-vault](https://github.com/panther-labs/tutorials/tree/master/aws-vault) |
| [EC2 Security Log Collection the Cloud-Native Way](https://blog.runpanther.io/cloud-native-security-log-collection/)      | [cloud-native-logging](https://github.com/panther-labs/tutorials/tree/master/cloud-native-logging) |   |   |
| [AWS Security Logging Fundamentals - CloudTrail](https://blog.runpanther.io/aws-cloudtrail-fundamentals/)      | [aws-security-logging](https://github.com/panther-labs/tutorials/tree/master/aws-security-logging) |   |   |
| [AWS Security Logging Fundamentals - S3 Bucket Access Logging](https://blog.runpanther.io/s3-bucket-access-logging/)      | [aws-security-logging](https://github.com/panther-labs/tutorials/tree/master/aws-security-logging) |   |   |
| [AWS Serverless Application Repository: Lambda and Beyond](https://blog.runpanther.io/serverless-app-repo-intro/)         | [serverless-app-repository](https://github.com/panther-labs/tutorials/tree/master/serverless-app-repository) |   |   |     

## Usage

This repo contains a `Makefile` with commands to use or deploy the provided code samples:

```bash
$ make deploy tutorial=<FOLDER> stack=<CLOUDFORMATION-FILENAME> region=<REGION>
```

## License

[Apache](https://choosealicense.com/licenses/apache-2.0/)
