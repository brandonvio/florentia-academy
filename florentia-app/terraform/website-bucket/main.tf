# /website-bucket/main.tf
# This template creates an S3 bucket for the website and uploads the index.html and error.html files to it.
resource "aws_s3_bucket" "website" {
  bucket = "home.florentia.academy"
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "website_index" {
  bucket       = aws_s3_bucket.website.id
  key          = "index.html"
  content_type = "text/html"
  source       = "website-bucket/files/index.html"
  etag         = filemd5("website-bucket/files/index.html")
}

resource "aws_s3_object" "website_error" {
  bucket       = aws_s3_bucket.website.id
  key          = "error.html"
  content_type = "text/html"
  source       = "website-bucket/files/error.html"
  etag         = filemd5("website-bucket/files/error.html")
}

output "website_bucket_id" {
  value = aws_s3_bucket.website.id
}

output "website_bucket_domain_name" {
  value = aws_s3_bucket.website.bucket_regional_domain_name
}
