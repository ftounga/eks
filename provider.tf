provider "aws" {
  profile = "eks"
  region  = "eu-west-1"
}

provider "tls" {

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.21"
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"   # Replace this with the specific version you need
    }
  }
}
