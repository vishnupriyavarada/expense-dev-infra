terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
  backend "s3" {
    bucket         = "expense-tf-remote-state-dev"
    key            = "expense-dev-rds"
    region         = "us-east-1"
    dynamodb_table = "expense-tf-remote-state-dev"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}