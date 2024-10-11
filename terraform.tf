# Terraform Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  /*
  backend "s3" {
    bucket = "espace-terraform-backend-2"
    key    = "Terraform-Backend/terraform.tfstate"
    region = "us-eas-1"
  }
  */
}
