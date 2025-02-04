resource "aws_cloudfront_origin_access_identity" "s3_origin_identity" {
  count = var.with_cloudfront ? 1 : 0
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  count = var.with_cloudfront ? 1 : 0
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.website_bucket.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_origin_identity[0].cloudfront_access_identity_path
    }
  }

  aliases = var.with_cloudfront ? var.cloudfront_aliases : []

  enabled             = true
  default_root_object = "index.html"

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

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.with_cloudfront ? var.acm_certificate_arn : null
    minimum_protocol_version = var.with_cloudfront ? "TLSv1.2_2021" : null
    ssl_support_method       = var.with_cloudfront ? "sni-only" : null
  }
}

output "cloudfront_domain_name" {
  value = var.with_cloudfront ? aws_cloudfront_distribution.s3_distribution[0].domain_name : null
}
