# Main Terraform Script

# Variables
variable "access_key" {
  description = "enter your AWS access_key!"
#  default = ""
}

variable "secret_key" {
  description = "enter your AWS secret_key!"
#  default = ""
}

variable "email" {
  description = "enter your email for notificatons"
  default = "maxim1fine@gmail.com"
}

variable "public_key" {
  description = "enter your AWS public_key from key pair!"
#  default = ""
}

variable "my_ip" {
  description = "enter cidr_blocks of IPs for SSH"
  default = "185.120.126.14/32"  # "0.0.0.0/0" My IP "185.120.126.14/32"
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create a local variable to load userdata using templatefile function.
locals {
  userdata = templatefile("userdata.sh", {
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
  })
}

# Create one EC2 resource with ami, instance profile and user_data parameters from the local variables.
resource "aws_instance" "this" {
  ami                  = "ami-03ededff12e34e59e" # Amazon Linux 2 Kernel 5.10 AMI 2.0.20220406.1 x86_64 HVM gp2
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.this.name
  user_data            = local.userdata
  key_name             = "Toluna_Keys"
  vpc_security_group_ids = [aws_security_group.this.id]
#  subnet_id = aws_subnet.this.id
  tags                 = { Name = "EC2-with-cw-agent" }
    # Send special I'm up! metric after EC2 instance creation complete
    provisioner "local-exec" {
    command = "aws cloudwatch put-metric-data --metric-name IAMUP_METRIC --namespace SPECIAL --value 1 --region us-east-1"
  }
}

# Create SSM Parameter resource and load its value from cw_agent_config.json
resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("cw_agent_config.json")
}

resource "aws_cloudwatch_metric_alarm" "Iamup" {
     alarm_name                = "I'm up!"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "1"
     metric_name               = "IAMUP_METRIC"
     namespace                 = "SPECIAL"
     period                    = "60" #seconds
     statistic                 = "Minimum"
     threshold                 = "0.5"
     alarm_description         = "This metric monitors I'm up! instance state"
     actions_enabled     = "true"
     alarm_actions       = [aws_sns_topic.aws_sns_topic.arn]
     insufficient_data_actions = []
#dimensions = {
#       InstanceId = aws_instance.this.id
#     }
}

# Create SNS topic to send Alerts
resource "aws_sns_topic" "aws_sns_topic" {
  name              = "aws_sns_topic"
#  kms_master_key_id = aws_kms_key.sns_encryption_key.id
  delivery_policy   = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
  # This local exec, suscribes your email to the topic
#  provisioner "local-exec" {
#    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.email}"
#  }
}

resource "aws_sns_topic_subscription" "aws_sns_topic_subscription" {
  topic_arn = aws_sns_topic.aws_sns_topic.arn
  protocol  = "email"
  endpoint  = var.email
#  endpoint_auto_confirms = true
#  confirmation_timeout_in_minutes = 5
}
## KMS Key to encrypt the SNS topic (security best practises)
#resource "aws_kms_key" "sns_encryption_key" {
#  description             = "alarms sns topic encryption key"
#  deletion_window_in_days = 30
#  enable_key_rotation     = true
#}

# Security
# Set Firewall that limits ingress cidr_blocks and open SSH port only
resource "aws_security_group" "this" {
  name        = "allow-all-sg"
#  vpc_id      = aws_vpc.this.id
  ingress {
    description      = "security_group"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
}

#resource "aws_key_pair" "this" {
#  key_name   = "Toluna_Keys"
#  public_key = var.public_key
#}

#resource "aws_key_pair" "deployer" {
#  key_name   = "Toluna_Keys"
#  public_key = var.public_key
#}
