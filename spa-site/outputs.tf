output "bucket_name" {
  description = "S3 bucket holding the site content"
  value       = aws_s3_bucket.site.bucket
}

output "distribution_id" {
  description = "CloudFront distribution id"
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_domain_name" {
  description = "CloudFront domain name"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "url" {
  description = "HTTPS URL of the site"
  value       = length(var.domain_aliases) > 0 ? "https://${var.domain_aliases[0]}" : "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "bucket_arn" {
  description = "ARN of the site bucket"
  value       = aws_s3_bucket.site.arn
}
