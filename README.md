# Panther Labs Tutorials

| Blog        | Code           
| ------------- |:-------------:|
| [Securing Multi-Account Access on AWS](https://medium.com/panther-labs/tutorial-securing-multi-account-access-on-aws-763c968bd4ce)      | [aws-vault](https://github.com/panther-labs/tutorials/tree/master/aws-vault) |
|| [Tutorial: EC2 Security Log Collection the Cloud-Native Way](https://medium.com/panther-labs/cloud-native-security-log-collection-d005cbc78665)      | [cloud-native-logging](https://github.com/panther-labs/tutorials/tree/master/cloud-native-logging) |   |   |

## Usage

This repo contains a `Makefile` with commands to use or deploy the provided code samples:

```bash
$ make deploy \
    tutorial=<tutorial-folder-name> \
    stack=<file-name-in-cfn-folder> \
    region=<aws-region>
```
