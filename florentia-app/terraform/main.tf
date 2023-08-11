provider "aws" {
  region = "us-west-2"
}

terraform {
  backend "s3" {
    bucket         = "florentia-academy-terraform-state"
    key            = "infrastructure/app/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "florentia_terraform_locks"
    encrypt        = true
  }
}

data "terraform_remote_state" "main_state" {
  backend = "s3"
  config = {
    bucket = "florentia-academy-terraform-state"
    key    = "infrastructure/terraform.tfstate"
    region = "us-west-2"
  }
}

module "florentia_website_bucket" {
  source = "./website-bucket"
}

# data "terraform_remote_state" "ssl" {
#   backend = "s3"
#   config = {
#     bucket = "lvrgd-ai-terraform-state"
#     key    = "dev/ssl-east-1/terraform.tfstate"
#     region = "us-west-2"
#   }
# }

# resource "aws_s3_bucket" "bucket" {
#   bucket = "home.florentia.academy"
# }

# resource "aws_s3_bucket_website_configuration" "website" {
#   bucket = aws_s3_bucket.bucket.id
#   index_document {
#     suffix = "index.html"
#   }
#   error_document {
#     key = "error.html"
#   }
# }

# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#   comment = "access-identity-home-lvrgd-ai"
# }

# resource "aws_cloudfront_distribution" "s3_distribution" {
#   origin {
#     domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
#     origin_id   = "S3-${aws_s3_bucket.bucket.id}"

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
#     }
#   }

#   aliases             = ["lvrgd.ai"]
#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"

#   default_cache_behavior {
#     allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "S3-${aws_s3_bucket.bucket.id}"

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#   }

#   price_class = "PriceClass_100"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   viewer_certificate {
#     acm_certificate_arn = data.terraform_remote_state.ssl.outputs.certificate_arn
#     ssl_support_method  = "sni-only"
#   }
# }

# resource "aws_route53_record" "root" {
#   name    = "lvrgd.ai"
#   type    = "A"
#   zone_id = data.terraform_remote_state.dns.outputs.zone_id
#   alias {
#     name                   = aws_cloudfront_distribution.s3_distribution.domain_name
#     zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
#     evaluate_target_health = false
#   }
# }
