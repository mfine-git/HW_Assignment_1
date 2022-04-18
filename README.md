
![logo](https://assets.greenbook.org/logos/toluna_primary_rgb_pp4206553637308425863395091.png)
## Homework assignment.
1. Create a free account in AWS. `# Done`
2. Create a machine (linux/docker) that on startup sends logs to Cloudwatch 
(system logs and special log that says "I'm up!"). `# System logs - Done, "I'm up!" via special metrics - Done`
3. Cloudwatch alert on the logs, when it receives "I'm up", it emails "The machine is up!" `# Done via metrics alert `
4. Build this infrastructure in Terraform. `# Done`

**Guidelines:**
- Security is very important to us. `# Security via firewall, keys and variables - Done`
- Try to be mindful of cost.  `# Сost reduction via Free tier eligible - Done`

**Super important:**
- The environment should be fully automated and be built and torn down with a script. `# Done via terraform apply/destroy except "Requirements" below` 
- Repo should include some documentation. `# Done via README.md and comments in code`
- The exercise should work out of the box without code tweaks according to the instructions you provided. `# Done`
- Submit this by April 20th. Send an email with a link to repo for review. `# Done by April 18th`

## How to use this project.
## Requirements:
- IDE (Pycharm with Terraform plugin)
- Terraform (for Windows-ARM64)
- E-mail (for notifications)
- AWS account (access and secret keys)
- AWS console (to monitor metrics,logs and alarms)
- [AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/install-windows.html#:~:text=Install%20and%20update%20the%20AWS%20CLI%20version%201%20using%20the%20MSI%20installer) version 1 for Windows (64-bit)
- Run "aws configure" to set access_key, secret_key, region=us-east-1, output_format=json
- EC2 "private_key" and "public_key" in format: "ssh-rsa ..." 

## Deployment:
**Run following from project folder using IDE local terminal:**
```
terraform init
terraform apply --auto-approve
```
## Monitoring:
Observe EC2-related Metrics and Logs in AWS Cloudwatch 

## E-mail notifications:
- Confirm subscription to SNS topic
- Expect "I'm up!" notification from new EC2 instance.

## Uninstall:
```
terraform destroy --auto-approve
```