# Main Terraform Script

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

# Create a local variable to load userdata using templatefile function.
locals {
  userdata = templatefile("userdata.sh", {
    ssm_cloudwatch_config = aws_ssm_parameter.cw_agent.name
  })
}

# Create one EC2 resource with ami from us-east-1, configure instance profile, and user_data from the local variables.
resource "aws_instance" "this" {
  ami                  = "ami-03ededff12e34e59e" # Amazon Linux 2 Kernel 5.10 AMI 2.0.20220406.1 x86_64 HVM gp2
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.this.name
  user_data            = local.userdata
  tags                 = { Name = "EC2-with-cw-agent" }
}

# Create SSM Parameter resource, and load its value from file cw_agent_config.json
resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("cw_agent_config.json")
}
