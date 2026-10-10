output "cloudfront_domain_name" {
  description = "CloudFront domain name (null without CloudFront)"
  value       = var.with_cloudfront ? aws_cloudfront_distribution.s3_distribution[0].domain_name : null
}

output "distribution_id" {
  description = "CloudFront distribution id (null without CloudFront)"
  value       = var.with_cloudfront ? aws_cloudfront_distribution.s3_distribution[0].id : null
}

output "bucket_name" {
  description = "S3 bucket holding the site content"
  value       = aws_s3_bucket.website_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the site bucket"
  value       = aws_s3_bucket.website_bucket.arn
}

output "url" {
  description = "URL of the site"
  value = (
    var.with_cloudfront
    ? "https://${length(var.cloudfront_aliases) > 0 ? var.cloudfront_aliases[0] : aws_cloudfront_distribution.s3_distribution[0].domain_name}"
    : "http://${aws_s3_bucket_website_configuration.website_configuration[0].website_endpoint}"
  )
}
