terraform {
  backend "s3" {


    bucket       = "crisbucket-md"
    key          = "data/dev/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true


  }
}


provider "aws" {
  region = var.region
}
