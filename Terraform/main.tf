terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}

resource "aws_instance" "Toluna_Server" {
  ami           = "ami-0e472ba40eb589f49"
  instance_type = "t2.micro"

  tags = {
    Name = "Toluna_Server"
  }
}

resource "aws_vpc" "Toluna_VPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Toluna_VPC"
  }
}

resource "aws_subnet" "Toluna_Subnet" {
  vpc_id     = aws_vpc.Toluna_VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Toluna_Subnet"
  }
}
