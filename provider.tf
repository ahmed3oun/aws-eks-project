#Terraform configuration for AWS provider.
terraform {
  required_providers {
    # Required AWS Provider
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.32.0"
    }
  }
  # Required Terraform version
  required_version = ">= 1.14.0"
}

# AWS Provider configuration
provider "aws" {
  region = "us-east-1"
}
