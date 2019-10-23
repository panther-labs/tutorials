# Panther Labs Tutorials
A Collection of Various Cloud Security Tutorials

## Contents

The code samples in this repo relate to the following blog posts:
* [Securing Multi-Account Access on AWS](https://medium.com/panther-labs/tutorial-securing-multi-account-access-on-aws-763c968bd4ce): `aws-vault`

## Usage

This repo contains a `Makefile` with commands to use or deploy the provided code samples:

```bash
$ make deploy \
    tutorial=<tutorial-folder-name> \
    stack=<file-name-in-cfn-folder> \
    region=<aws-region>
```
