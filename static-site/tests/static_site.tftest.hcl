mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
}

variables {
  domain_name = "app.example.com"
}

run "public_website_is_default" {
  command = plan

  variables {
    with_cloudfront = false
  }

  assert {
    condition     = length(aws_s3_bucket_website_configuration.website_configuration) == 1
    error_message = "The website endpoint must be on by default."
  }

  assert {
    condition     = !aws_s3_bucket_public_access_block.example.block_public_policy
    error_message = "The default bucket stays public (v1 behaviour)."
  }
}

run "cloudfront_without_custom_domain_uses_default_certificate" {
  command = plan

  variables {
    with_cloudfront = true
  }

  assert {
    condition     = aws_cloudfront_distribution.s3_distribution[0].viewer_certificate[0].cloudfront_default_certificate
    error_message = "Without a certificate ARN the default CloudFront certificate is used."
  }

  assert {
    condition     = length(aws_cloudfront_distribution.s3_distribution[0].custom_error_response) == 0
    error_message = "No SPA fallback unless spa_mode is set."
  }
}

run "private_spa" {
  command = plan

  variables {
    with_cloudfront = true
    private_bucket  = true
    spa_mode        = true
  }

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.example.block_public_acls,
      aws_s3_bucket_public_access_block.example.block_public_policy,
      aws_s3_bucket_public_access_block.example.ignore_public_acls,
      aws_s3_bucket_public_access_block.example.restrict_public_buckets,
    ])
    error_message = "The bucket must not be public."
  }

  assert {
    condition     = length(aws_s3_bucket_website_configuration.website_configuration) == 0
    error_message = "A private bucket has no website endpoint."
  }

  assert {
    condition = toset([
      for r in aws_cloudfront_distribution.s3_distribution[0].custom_error_response : r.response_page_path
    ]) == toset(["/index.html"])
    error_message = "403 and 404 must fall back to index.html."
  }
}

run "private_bucket_needs_cloudfront" {
  command = plan

  variables {
    with_cloudfront = false
    private_bucket  = true
  }

  expect_failures = [var.private_bucket]
}

run "custom_domain_needs_certificate" {
  command = plan

  variables {
    with_cloudfront    = true
    cloudfront_aliases = ["app.example.com"]
  }

  expect_failures = [var.cloudfront_aliases]
}
