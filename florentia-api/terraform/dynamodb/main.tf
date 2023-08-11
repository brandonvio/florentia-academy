# Terraform module for creating a DynamoDB table for the Course Enrollment service.

resource "aws_dynamodb_table" "florentia_academy_db" {
  name         = "florentia-academy-db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "PK"
  range_key    = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Name = "florentia-academy-db"
  }
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.florentia_academy_db.arn
}
