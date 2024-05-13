provider "aws" {
    region = "us-east-1"
}

terraform {
	backend "s3" {
		bucket = "terra-state-bucket"
		key = "statefile"
		region = "us-east-1"
	}
}
