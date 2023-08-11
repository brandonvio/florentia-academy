provider "aws" {
  region = "us-west-2"
}

variable "zone_id" {
  description = "The Route53 Zone ID from the dns module"
  type        = string
}

resource "aws_acm_certificate" "cert" {
  domain_name               = "*.florentia.academy"
  validation_method         = "DNS"
  subject_alternative_names = ["florentia.academy"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_dns" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id         = var.zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_dns.fqdn]
}

output "certificate_arn" {
  description = "The ARN of the created SSL certificate"
  value       = aws_acm_certificate.cert.arn
}
