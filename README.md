# Panther Labs Tutorials

| Blog        | Code           
| ------------- |:-------------:|
| [Securing Multi-Account Access on AWS](https://medium.com/panther-labs/tutorial-securing-multi-account-access-on-aws-763c968bd4ce)      | [aws-vault](https://github.com/panther-labs/tutorials/tree/master/aws-vault) |
| [EC2 Security Log Collection the Cloud-Native Way](https://medium.com/panther-labs/cloud-native-security-log-collection-d005cbc78665)      | [cloud-native-logging](https://github.com/panther-labs/tutorials/tree/master/cloud-native-logging) |   |   |
| [AWS Security Logging Fundamentals - CloudTrail](https://medium.com/panther-labs/aws-security-logging-fundamentals-cloudtrail-c7733789a5dd)      | [aws-security-logging](https://github.com/panther-labs/tutorials/tree/master/aws-security-logging) |   |   |

## Usage

This repo contains a `Makefile` with commands to use or deploy the provided code samples:

```bash
$ make deploy tutorial=<FOLDER> stack=<CLOUDFORMATION-FILENAME> region=<REGION>
```
