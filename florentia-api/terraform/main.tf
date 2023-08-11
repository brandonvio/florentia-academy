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
  source = "./iam"
}

# import the lambda module
module "florentia_api_lambda" {
  source          = "./lambda"
  github_sha      = var.github_sha
  lambda_exec_arn = module.florentia_api_iam.lambda_exec_arn
}

# resource "aws_cloudwatch_log_group" "lambda_log_group" {
#   name              = "/aws/lambda/${aws_lambda_function.florentia_api.function_name}"
#   retention_in_days = 14 # adjust this to fit your requirements
# }

# resource "aws_lambda_permission" "allow_cloudwatch" {
#   statement_id  = "AllowExecutionFromCloudWatch"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.florentia_api.function_name
#   principal     = "logs.us-west-2.amazonaws.com"

#   source_arn = "arn:aws:logs:us-west-2:504727947636:log-group:/aws/lambda/${aws_lambda_function.florentia_api.function_name}:*"
# }

# data "aws_iam_policy_document" "lambda_exec" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "lambda_exec" {
#   name               = "lambda_exec_role"
#   assume_role_policy = data.aws_iam_policy_document.lambda_exec.json
# }

# resource "aws_iam_role_policy_attachment" "attach_lambda_basic_execution" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }


# resource "aws_api_gateway_rest_api" "florentia_api" {
#   name        = "florentia_api"
#   description = "User API"
# }

# resource "aws_api_gateway_resource" "proxy" {
#   rest_api_id = aws_api_gateway_rest_api.florentia_api.id
#   parent_id   = aws_api_gateway_rest_api.florentia_api.root_resource_id
#   path_part   = "{proxy+}"
# }

# resource "aws_api_gateway_method" "proxy" {
#   rest_api_id   = aws_api_gateway_rest_api.florentia_api.id
#   resource_id   = aws_api_gateway_resource.proxy.id
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda" {
#   rest_api_id = aws_api_gateway_rest_api.florentia_api.id
#   resource_id = aws_api_gateway_method.proxy.resource_id
#   http_method = aws_api_gateway_method.proxy.http_method

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.florentia_api.invoke_arn
# }

# resource "aws_api_gateway_method" "proxy_root" {
#   rest_api_id   = aws_api_gateway_rest_api.florentia_api.id
#   resource_id   = aws_api_gateway_rest_api.florentia_api.root_resource_id
#   http_method   = "ANY"
#   authorization = "NONE"
# }

# resource "aws_api_gateway_integration" "lambda_root" {
#   rest_api_id = aws_api_gateway_rest_api.florentia_api.id
#   resource_id = aws_api_gateway_method.proxy_root.resource_id
#   http_method = aws_api_gateway_method.proxy_root.http_method

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.florentia_api.invoke_arn
# }

# resource "aws_api_gateway_deployment" "florentia_api" {
#   depends_on = [
#     aws_api_gateway_integration.lambda,
#     aws_api_gateway_integration.lambda_root,
#   ]

#   rest_api_id = aws_api_gateway_rest_api.florentia_api.id
#   stage_name  = "prod"
# }

# resource "aws_lambda_permission" "apigw" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.florentia_api.function_name
#   principal     = "apigateway.amazonaws.com"

#   # The /*/* portion grants access from any method on any resource
#   # within the API Gateway "REST API".
#   source_arn = "${aws_api_gateway_rest_api.florentia_api.execution_arn}/*/*"
# }

# output "base_url" {
#   value = aws_api_gateway_deployment.florentia_api.invoke_url
# }

# data "aws_iam_policy_document" "dynamodb_access" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "dynamodb:GetItem",
#       "dynamodb:PutItem",
#       "dynamodb:UpdateItem",
#       "dynamodb:DeleteItem",
#       "dynamodb:Scan",
#       "dynamodb:Query",
#     ]

#     resources = [
#       "arn:aws:dynamodb:us-west-2:504727947636:*",
#     ]
#   }
# }

# resource "aws_iam_policy" "dynamodb_access" {
#   name   = "DynamoDBAccessPolicy"
#   policy = data.aws_iam_policy_document.dynamodb_access.json
# }

# resource "aws_iam_role_policy_attachment" "dynamodb_access" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = aws_iam_policy.dynamodb_access.arn
# }

# ## DNS and SSL
# # Add a custom domain name to API Gateway
# resource "aws_apigatewayv2_domain_name" "api_gateway_domain" {
#   domain_name = "api.forentia.academy"
#   domain_name_configuration {
#     certificate_arn = data.terraform_remote_state.ssl.outputs.certificate_arn
#     endpoint_type   = "REGIONAL"
#     security_policy = "TLS_1_2"
#   }
# }

# # Create an API mapping to map the custom domain to the API
# resource "aws_apigatewayv2_api_mapping" "api_mapping" {
#   api_id      = aws_api_gateway_rest_api.florentia_api.id
#   domain_name = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name
#   stage       = aws_api_gateway_deployment.florentia_api.stage_name
# }

# # Create a Route53 record to point to the custom domain
# resource "aws_route53_record" "api_gateway_record" {
#   zone_id = data.terraform_remote_state.dns.outputs.zone_id
#   name    = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name
#   type    = "A"

#   alias {
#     name                   = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name_configuration.0.target_domain_name
#     zone_id                = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name_configuration.0.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# # Replace the base_url output with the custom domain name
# output "base_url_with_domain" {
#   value = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name
# }
