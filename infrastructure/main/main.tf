provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "florentia-academy-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "florentia_terraform_locks"
    encrypt        = true
  }
}

module "florentia_dns" {
  source = "./dns"
}

module "florentia_ssl" {
  source  = "./ssl-east-1"
  zone_id = module.florentia_dns.zone_id
}

module "florentia_ssl_west" {
  source  = "./ssl-west-2"
  zone_id = module.florentia_dns.zone_id
}
