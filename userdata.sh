#! /bin/bash
# User data file that initializes the EC2 set up
set -e

# Output all log to the specified location
exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

# Upgrade the machine
yum update -y
yum upgrade -y

# Configure Cloudwatch agent with download package from AWS and install it
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Run the cloud watch agent with configuring it to use config from SSM from main.tf.
# We use a template file to load the file, so we can replace ours SSM config value.
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:"${ssm_cloudwatch_config}" -s

echo 'Done initialization'
