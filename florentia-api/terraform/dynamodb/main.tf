# Terraform module for creating a DynamoDB table for the Course Enrollment service.
provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "florentia-academy-terraform-state"
    key            = "infrastructure/dynamodb/florentia_academy_db/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "florentia_terraform_locks"
    encrypt        = true
  }
}

resource "aws_dynamodb_table" "florentia_academy_db" {
  name         = "florentia_academy_db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  tags = {
    Name = "florentia_academy_db"
  }
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.florentia_academy_db.arn
}
