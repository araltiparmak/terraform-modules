variable "domain_name" {
  type = string
}

variable "with_cloudfront" {
  type = bool
}

variable "cloudfront_aliases" {
  type = list(string)
}

variable "acm_certificate_arn" {
  type = string
}
