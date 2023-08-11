# /cloudfront/main.tf
# This template creates a CloudFront distribution for the website.
variable "website_bucket_id" {
  type = string
}

variable "website_bucket_domain_name" {
  type = string
}

variable "ssl_certificate_arn" {
  type = string
}

variable "aws_region" {
  type = string
}


resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-home-florentia-academy"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = var.website_bucket_domain_name
    origin_id   = "S3-${var.website_bucket_id}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  aliases             = ["florentia.academy"]
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.website_bucket_id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.ssl_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

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
