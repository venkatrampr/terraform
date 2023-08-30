terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-2"
}

resource "aws_instance" "test_terraform" {
  ami           = "ami-0911e88fb4687e06b"
  instance_type = "t2.micro"

  tags = {
    Name = "Alephys"
    Purpose = "Terraform Testing"
  }
}
