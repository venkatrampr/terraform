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
  ami           = "ami-0cf0e376c672104d6"
  instance_type = "t2.micro"

  tags = {
    Name = "Alephys"
    Purpose = "Terraform Testing"
  }
}
