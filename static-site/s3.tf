resource "aws_s3_bucket" "website_bucket" {
  bucket = var.domain_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = var.private_bucket
  block_public_policy     = var.private_bucket
  ignore_public_acls      = var.private_bucket
  restrict_public_buckets = var.private_bucket
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = var.private_bucket ? data.aws_iam_policy_document.cloudfront_oac[0].json : data.aws_iam_policy_document.website_iam_policy[0].json

  depends_on = [aws_s3_bucket_public_access_block.example]
}

# The website endpoint is only used for the public bucket. A private bucket is
# read through the S3 REST endpoint with OAC.
resource "aws_s3_bucket_website_configuration" "website_configuration" {
  count = var.private_bucket ? 0 : 1

  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

moved {
  from = aws_s3_bucket_website_configuration.website_configuration
  to   = aws_s3_bucket_website_configuration.website_configuration[0]
}
