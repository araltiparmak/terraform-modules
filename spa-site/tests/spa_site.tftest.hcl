mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}" }
  }
}

variables {
  bucket_name = "app-prod-frontend-123456789012"
}

run "private_bucket_spa_fallback" {
  command = plan

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.site.block_public_acls,
      aws_s3_bucket_public_access_block.site.block_public_policy,
      aws_s3_bucket_public_access_block.site.ignore_public_acls,
      aws_s3_bucket_public_access_block.site.restrict_public_buckets,
    ])
    error_message = "The bucket must not be public."
  }

  assert {
    condition = toset([
      for r in aws_cloudfront_distribution.site.custom_error_response : r.response_page_path
    ]) == toset(["/index.html"])
    error_message = "403 and 404 must fall back to index.html."
  }

  assert {
    condition     = aws_cloudfront_distribution.site.default_cache_behavior[0].viewer_protocol_policy == "redirect-to-https"
    error_message = "HTTP must redirect to HTTPS."
  }
}

run "custom_domain_needs_certificate" {
  command = plan

  variables {
    domain_aliases = ["app.example.com"]
  }

  expect_failures = [var.acm_certificate_arn]
}
