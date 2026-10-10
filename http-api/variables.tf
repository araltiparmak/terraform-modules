variable "name" {
  type = string
}

variable "routes" {
  description = "Route keys, e.g. \"GET /posts/{id}\". All go to the Lambda behind the JWT authorizer."
  type        = list(string)
}

variable "lambda_invoke_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "jwt_issuer" {
  description = "OIDC issuer URL, e.g. the Cognito user pool authority."
  type        = string
}

variable "jwt_audience" {
  type = list(string)
}

variable "cors_allow_origins" {
  type = list(string)
}

variable "cors_allow_methods" {
  type    = list(string)
  default = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  type    = list(string)
  default = ["authorization", "content-type"]
}

variable "throttling_burst_limit" {
  type    = number
  default = 50
}

variable "throttling_rate_limit" {
  type    = number
  default = 100
}

variable "tags" {
  type    = map(string)
  default = {}
}
