variable "domain_name" {
  type = string
}

variable "with_cloudfront" {
  type = bool
}

variable "cloudfront_aliases" {
  type    = list(string)
  default = []
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}
