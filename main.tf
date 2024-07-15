terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ca-central-1"
}

module "pcoi_api_gateway" {
  source       = "./pcoi"
  stage_name   = "dev101"
  backbone_url = "http://k8s-oagfarga-backbone-a03b7ea046-5ea3c894b1bc6d7c.elb.ca-central-1.amazonaws.com/backbone" 
  lob_url      = "http://localhost:8080/dummy"
}