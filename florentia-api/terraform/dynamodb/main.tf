# Terraform module for creating a DynamoDB table for the Course Enrollment service.

resource "aws_dynamodb_table" "florentia_academy_db" {
  name           = "florentia_academy_db"
  billing_mode   = "PROVISIONED"
  read_capacity  = 15
  write_capacity = 15
  hash_key       = "pk"
  range_key      = "sk"

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
