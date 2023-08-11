provider "aws" {
  region = "us-west-2"
}

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
  bucket = aws_s3_bucket.website.id
  key    = "index.html"
  source = "website-bucket/files/index.html"
  acl    = "public-read"
  etag   = filemd5("website-bucket/files/index.html")
}

resource "aws_s3_object" "website_error" {
  bucket = aws_s3_bucket.website.id
  key    = "error.html"
  source = "website-bucket/files/error.html"
  acl    = "public-read"
  etag   = filemd5("website-bucket/files/error.html")
}
