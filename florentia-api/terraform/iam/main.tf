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

# output the role arn so it can be used by the lambda function
output "lambda_exec_arn" {
  value = aws_iam_role.florentia_lambda_exec.arn
}
