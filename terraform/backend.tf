terraform {
  backend "s3" {
    bucket         = "crisbucket-md"
    key            = "data/dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}



provider "aws" {
  region = var.region
}
