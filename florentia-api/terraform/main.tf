# This is the main template for the Florentia API
provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "florentia-academy-terraform-state"
    key            = "infrastructure/api/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "florentia_terraform_locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "main" {
  backend = "s3"
  config = {
    bucket = "florentia-academy-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"
  }
}

variable "github_sha" {
  description = "GitHub Hash"
  type        = string
}

module "florentia_api_iam" {
  source     = "./iam"
  region     = "us-west-2"
  account_id = data.terraform_remote_state.main.outputs.account_id
}

# import the lambda module
module "florentia_api_lambda" {
  source          = "./lambda"
  github_sha      = var.github_sha
  lambda_exec_arn = module.florentia_api_iam.lambda_exec_arn
  bucket          = data.terraform_remote_state.main.outputs.florentia_lambda_functions_bucket_name
  region          = "us-west-2"
  account_id      = data.terraform_remote_state.main.outputs.account_id
  depends_on      = [module.florentia_api_iam]
}

module "florentia_api_api_gateway" {
  source               = "./api-gateway"
  lambda_invoke_arn    = module.florentia_api_lambda.florentia_api_lambda_invoke_arn
  lambda_function_name = module.florentia_api_lambda.florentia_api_lambda_function_name
  ssl_certificate_arn  = data.terraform_remote_state.main.outputs.west_ssl_certifcate_arn
  zone_id              = data.terraform_remote_state.main.outputs.zone_id
  depends_on           = [module.florentia_api_lambda]
}

# module "florentia_api_dynamodb" {
#   source = "./dynamodb"
# }
