# This template creates an API Gateway that will trigger the lambda function we created in the previous step.

variable "lambda_invoke_arn" {
  description = "Lambda Invoke ARN"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda Function Name"
  type        = string
}

variable "ssl_certificate_arn" {
  description = "SSL Certificate ARN"
  type        = string
}

variable "zone_id" {
  description = "Zone ID"
  type        = string
}

resource "aws_api_gateway_rest_api" "florentia_api" {
  name        = "florentia_api"
  description = "API for the Florentia Academy enrollment system"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.florentia_api.id
  parent_id   = aws_api_gateway_rest_api.florentia_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.florentia_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.florentia_api.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.florentia_api.id
  resource_id   = aws_api_gateway_rest_api.florentia_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.florentia_api.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_api_gateway_deployment" "florentia_api" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.florentia_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.florentia_api.execution_arn}/*/*"
}

output "base_url" {
  value = aws_api_gateway_deployment.florentia_api.invoke_url
}


# ## DNS and SSL
# # Add a custom domain name to API Gateway
resource "aws_apigatewayv2_domain_name" "api_gateway_domain" {
  domain_name = "api.florentia.academy"
  domain_name_configuration {
    certificate_arn = var.ssl_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Create an API mapping to map the custom domain to the API
resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_api_gateway_rest_api.florentia_api.id
  domain_name = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name
  stage       = aws_api_gateway_deployment.florentia_api.stage_name
}

# Create a Route53 record to point to the custom domain
resource "aws_route53_record" "api_gateway_record" {
  zone_id = var.zone_id
  name    = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name_configuration.0.target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name_configuration.0.hosted_zone_id
    evaluate_target_health = false
  }
}

# Replace the base_url output with the custom domain name
output "base_url_with_domain" {
  value = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name
}
