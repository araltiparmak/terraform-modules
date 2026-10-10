variable "domain_name" {
  description = "Bucket name (usually the site's domain name)"
  type        = string
}

variable "with_cloudfront" {
  description = "Put a CloudFront distribution in front of the bucket"
  type        = bool
}

variable "cloudfront_aliases" {
  description = "Custom domain names for the CloudFront distribution"
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.cloudfront_aliases) == 0 || var.acm_certificate_arn != ""
    error_message = "acm_certificate_arn is required when cloudfront_aliases is set."
  }
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (us-east-1). Empty uses the default *.cloudfront.net certificate."
  type        = string
  default     = ""
}

variable "error_document" {
  description = "Error page of the S3 website endpoint (ignored when private_bucket is true)"
  type        = string
  default     = "error.html"
}

variable "index_document" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "private_bucket" {
  description = "Keep the bucket private and let only CloudFront read it (OAC). Requires with_cloudfront."
  type        = bool
  default     = false

  validation {
    condition     = !var.private_bucket || var.with_cloudfront
    error_message = "private_bucket requires with_cloudfront = true."
  }
}

variable "spa_mode" {
  description = "Serve index_document with status 200 for unknown paths (403/404), so client-side routing survives a page refresh. Requires with_cloudfront."
  type        = bool
  default     = false

  validation {
    condition     = !var.spa_mode || var.with_cloudfront
    error_message = "spa_mode requires with_cloudfront = true."
  }
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Tags applied to the bucket and the distribution"
  type        = map(string)
  default     = {}
}
