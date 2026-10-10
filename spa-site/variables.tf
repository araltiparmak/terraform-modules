variable "bucket_name" {
  description = "Globally unique name for the S3 bucket holding the site content"
  type        = string
}

variable "index_document" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "domain_aliases" {
  description = "Optional custom domain aliases for the CloudFront distribution"
  type        = list(string)
  default     = []
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (us-east-1) — required when domain_aliases is set"
  type        = string
  default     = null

  validation {
    condition     = length(var.domain_aliases) == 0 || var.acm_certificate_arn != null
    error_message = "acm_certificate_arn is required when domain_aliases is set."
  }
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
