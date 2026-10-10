variable "function_name" {
  description = "Lambda function name; also names the role and the log group."
  type        = string
}

variable "source_dir" {
  description = "Directory with the built handler, zipped as the deployment package."
  type        = string
}

variable "handler" {
  type    = string
  default = "index.handler"
}

variable "runtime" {
  type    = string
  default = "nodejs22.x"
}

variable "architectures" {
  type    = list(string)
  default = ["arm64"]
}

variable "memory_size" {
  type    = number
  default = 512
}

variable "timeout" {
  description = "Seconds."
  type        = number
  default     = 30
}

variable "ephemeral_storage_mb" {
  description = "/tmp size in MB (512-10240)."
  type        = number
  default     = 512
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "inline_policy_json" {
  description = "What the function may do (IAM policy JSON). Logging is always allowed."
  type        = string
  default     = null
}

variable "permissions_boundary_arn" {
  description = "Permissions boundary for the function's role."
  type        = string
  default     = null
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "async_max_retry_attempts" {
  description = "Retries for asynchronous invocations (0-2). null keeps the AWS default (2)."
  type        = number
  default     = null

  validation {
    condition     = var.async_max_retry_attempts == null || (var.async_max_retry_attempts >= 0 && var.async_max_retry_attempts <= 2)
    error_message = "async_max_retry_attempts must be between 0 and 2."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
