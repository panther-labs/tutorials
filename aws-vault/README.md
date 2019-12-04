# Tutorial: Securing Multi-Account Access on AWS

*Check out the article on [Medium](https://medium.com/panther-labs/tutorial-securing-multi-account-access-on-aws-763c968bd4ce)*

As a company’s cloud footprint grows, it becomes increasingly important for security teams to effectively centralize and provide secure access to the cloud. Organizations across the globe are realizing the importance of investing in safer and robust programmatic access to the cloud. This ensures that cloud security investments are aligned to the most cutting-edge security best practices to mitigate current and future challenges.

In this step-by-step tutorial, we will show you exactly how you can equip and enhance your IT and security operations against unauthorized access and sophisticated attacks by setting up secure access across multiple accounts using [aws-vault](https://github.com/99designs/aws-vault).

In AWS, access keys provide programmatic access to accounts. Normally, they are stored in plaintext files and used by engineers to perform a certain job function. If these access keys are compromised, it could result in irreparable damage to infrastructure, data loss, or destruction of systems.

Thankfully, there are techniques that can prevent this type of attack:
* Enforcing MFA: Add an extra layer of protection to an access key or password using Google Authenticator, DUO, 1Password, etc.
* Generating Temporary Credentials: Dynamically generated credentials that last expire after a configurable interval.
* Encryption: Avoid plaintext storage of long or short term credentials.
* Centralized User Management: Dedicated “Identity” accounts to centralize all users and groups and enforce least privilege. Federated access can also be setup with systems such as Okta or OneLogin.

## Getting Started
Before we get started with setting up and implementing secure multi-account access on AWS, please ensure you have the following installed:
* [aws-vault](https://github.com/99designs/aws-vault)
* [aws-cli](https://docs.aws.amazon.com/en_pv/cli/latest/userguide/cli-chap-install.html)
* `git clone git@github.com:panther-labs/tutorials.git`

Let’s try to understand this with an example scenario. Imagine you manage an engineer named Franklin who is responsible for deploying web applications running on AWS ElasticBeanstalk. He needs secured and temporary access to a `WebAdmin` role in the company’s Production account with the minimum set of permissions required.

### Step 1: Setup Identity Account
The first step is to setup an Identity AWS account to contain our IAM groups, users, and secret access keys. Users in this account have permissions to assume specific roles across several accounts along with managing their passwords/access keys.
Create the CloudFormation stacks below to setup IAM users and groups with `AssumeRole` and `ForceMFA` policies:

```
# Run these commands from the panther-labs/tutorials
$ make deploy tutorial=aws-vault stack=identity-account-iam-users region=us-east-1
$ make deploy tutorial=aws-vault stack=identity-account-iam-groups region=us-east-1
```

When these stacks complete, login to the AWS Console and configure a MFA device and a new set of access keys for our user, Franklin. Store the access key ID and secret access key in a password manager until `aws-vault` is configured.

### Step 2: Setup Production Account
The next step is to allow Franklin to assume the WebAdmin role. This permission is bidirectional, the source and destination account must allow the AssumeRole.Create the CloudFormation stack below in the Production account to enable the destination access:

```bash
$ make deploy tutorial=aws-vault stack=production-account-iam-groups region=us-east-1
```

Note: The IAM role in this stack is assumable from any principal in the Identity account. This is because there is strict group membership in place on the Identity account to allow for least privilege.

### Step 3: Setup AWS Vault
The final step is configuring aws-vault to use the newly created roles by requesting temporary credentials and storing them with encryption. Use the long-term credentials created in Step 1 when prompted below:

```
$ aws-vault add identity
  Enter Access Key Id: ABDCDEFDASDASF
  Enter Secret Key: %%%%%%%%%%%%%
```

Then open the ~/aws./config file, and add a new profile:

```
###### web-admin #####
[profile web-admin]
source_profile = identity
role_arn = arn:aws:iam::<prod-account-id>:role/WebAdmin
mfa_serial = arn:aws:iam::<identity-account-id>:mfa/franklin
```

### Step 4: Practical Usage
This is where everything gets tied together! Run the command below to use the newly created role:

```
$ aws-vault exec web-admin -- aws elasticbeanstalk describe-applications
Enter token for arn:aws:iam::123456789012:mfa/franklin: %%%%%%
{
  "Applications": [
    {
      "ApplicationName": "prod-app",
      "ConfigurationTemplates": [],
      "DateUpdated": "2019–10–20T21:05:44.376Z",
      "Versions": [
        "Sample Application"
      ],
      "DateCreated": "2018–08–13T21:05:44.376Z"
    }
  ]
}
```

That’s it! You have successfully setup multi-account delegation with enforced MFA, least privilege, and data encryption on access keys.

## How It Works

The steps in this tutorial lay the groundwork for secure, multi-account AWS access. This permission pattern can be further applied with any number of additional accounts:

1. Using “Identity” account credentials, a user assumes a role in another account.
2. The AssumeRole call returns temporary credentials, which aws-vault stores securely in the MacOS Keychain or other supported backend.
3. User performs actions using encrypted AssumeRole credentials, and refreshes them once expired.

These commands are possible with the `aws-cli`, but `aws-vault` makes it convenient by providing a safe way to manage temporary sessions, store access keys, and switch between profiles.

## Conclusion
In this tutorial, we setup secured programmatic access to multiple AWS accounts. This reduces common attacks where sensitive credentials are long lived and stored in plaintext.
Before, a leaked developer access key could compromise your production infrastructure. Now, IAM user access keys can only assume roles with a valid MFA token. This means an attacker with a stolen access key will only be able to see basic IAM information about the user, with no access to any of your production accounts.

## But Wait, There’s More
To learn how you can define such security controls defined above as code and monitor all of your AWS accounts at scale, be sure to check out [Panther](https://runpanther.io/request-a-demo/).
Panther analyzes real-time changes to AWS resources using a Python-based Policy engine and sends alerts when vulnerable resources are found. Resources attributes can additionally be visualized in the UI.
