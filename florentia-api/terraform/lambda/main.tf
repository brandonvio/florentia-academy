# This template creates a lambda function that will be triggered by an API Gateway.

variable "github_sha" {
  description = "GitHub Hash"
  type        = string
}

variable "lambda_exec_arn" {
  description = "Lambda Execution Role ARN"
  type        = string
}

variable "bucket" {
  description = "S3 Bucket Name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

resource "aws_lambda_function" "florentia_api" {
  function_name = "florentia_api"
  s3_bucket     = var.bucket
  s3_key        = "florentia-api/${var.github_sha}/florentia-api.zip"
  handler       = "florentia-api-exe"
  runtime       = "go1.x"
  role          = var.lambda_exec_arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.florentia_api.function_name}"
  retention_in_days = 14 # adjust this to fit your requirements
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.florentia_api.function_name
  principal     = "logs.${var.region}.amazonaws.com"
  source_arn    = "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/lambda/${aws_lambda_function.florentia_api.function_name}:*"
}


# output the lambda function ARN
output "florentia_api_lambda_function_arn" {
  value = aws_lambda_function.florentia_api.arn
}

# output the invoke arn
output "florentia_api_lambda_invoke_arn" {
  value = aws_lambda_function.florentia_api.invoke_arn
}

output "florentia_api_lambda_function_name" {
  value = aws_lambda_function.florentia_api.function_name
}

