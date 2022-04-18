#! /bin/bash
# User data file that initializes the EC2 set up
set -e

# Output all logs to the specified location
exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1

# Upgrade the machine
yum update -y
yum upgrade -y

# Configure Cloudwatch agent with download package from AWS and install it
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Run the cloud watch agent with configuring it to use config from SSM from main.tf.
# Template used to load  SSM config value.
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:"${ssm_cloudwatch_config}" -s

#cd ~
#echo "I am up." > /var/log/up.log
#pwd

#aws cloudwatch put-metric-data --metric-name SYSTEM_METRIC --namespace CWAgent --value 0.3 --timestamp 2022-04-16T13:00:00.000Z --region us-east-1
#aws cloudwatch put-metric-data --metric-name IAMUP_METRIC --namespace SPECIAL --value 0.4 --timestamp 2022-04-16T13:00:00.000Z --region us-east-1
#aws cloudwatch put-metric-data --metric-name SYSTEM_METRIC --namespace CWAgent --value 0.5 --region us-east-1
#aws cloudwatch put-metric-data --metric-name IAMUP_METRIC --namespace SPECIAL --value 0.4 --region us-east-1

echo 'Done initialization'
