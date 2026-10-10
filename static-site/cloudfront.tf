locals {
  custom_certificate = var.acm_certificate_arn != ""
}

resource "aws_cloudfront_origin_access_control" "oac" {
  count = var.private_bucket ? 1 : 0

  name                              = "${var.domain_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  count = var.with_cloudfront ? 1 : 0

  origin {
    domain_name              = var.private_bucket ? aws_s3_bucket.website_bucket.bucket_regional_domain_name : aws_s3_bucket_website_configuration.website_configuration[0].website_endpoint
    origin_id                = aws_s3_bucket.website_bucket.id
    origin_access_control_id = var.private_bucket ? aws_cloudfront_origin_access_control.oac[0].id : null

    dynamic "custom_origin_config" {
      for_each = var.private_bucket ? [] : [1]

      content {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1.2"]
      }
    }
  }

  aliases = var.with_cloudfront ? var.cloudfront_aliases : []
  tags    = var.tags

  enabled             = true
  default_root_object = var.index_document

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.website_bucket.id
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  # SPA fallback: the app router owns unknown paths.
  dynamic "custom_error_response" {
    for_each = var.spa_mode ? [403, 404] : []

    content {
      error_code            = custom_error_response.value
      response_code         = 200
      response_page_path    = "/${var.index_document}"
      error_caching_min_ttl = 10
    }
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = !local.custom_certificate
    acm_certificate_arn            = local.custom_certificate ? var.acm_certificate_arn : null
    minimum_protocol_version       = local.custom_certificate ? "TLSv1.2_2021" : null
    ssl_support_method             = local.custom_certificate ? "sni-only" : null
  }
}
