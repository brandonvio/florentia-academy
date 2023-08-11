variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

data "aws_iam_policy_document" "lambda_exec" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "florentia_lambda_exec" {
  name               = "florentia_lambda_exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
}

resource "aws_iam_role_policy_attachment" "attach_lambda_basic_execution" {
  role       = aws_iam_role.florentia_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "florentia_dynamodb_access" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
    ]

    resources = [
      "arn:aws:dynamodb:${var.region}:${var.account_id}:*",
    ]
  }
}

resource "aws_iam_policy" "florentia_dynamodb_access" {
  name   = "FlorentiaDynamoDBAccessPolicy"
  policy = data.aws_iam_policy_document.florentia_dynamodb_access.json
}

resource "aws_iam_role_policy_attachment" "florentia_dynamodb_access" {
  role       = aws_iam_role.florentia_lambda_exec.name
  policy_arn = aws_iam_policy.florentia_dynamodb_access.arn
}

# output the role arn so it can be used by the lambda function
output "lambda_exec_arn" {
  value = aws_iam_role.florentia_lambda_exec.arn
}
