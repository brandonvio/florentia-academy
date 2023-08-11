# This template creates a lambda function that will be triggered by an API Gateway.

variable "github_sha" {
  description = "GitHub Hash"
  type        = string
}

variable "lambda_exec_arn" {
  description = "Lambda Execution Role ARN"
  type        = string
}

resource "aws_lambda_function" "florentia_api" {
  function_name = "florentia_api"
  s3_bucket     = aws_s3_bucket.florentia_api_lambda.bucket
  s3_key        = "florentia-api/${var.github_sha}/florentia-api.zip"
  handler       = "florentia-api-exe"
  runtime       = "go1.x"
  role          = lambda_exec_arn
}
