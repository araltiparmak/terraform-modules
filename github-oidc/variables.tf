variable "github_account" {
  description = "GitHub user or organisation that owns the repository."
  type        = string
}

variable "repo" {
  description = "Repository name, without the owner."
  type        = string
}

variable "role_name" {
  description = "IAM role name. Defaults to github-actions-<github_account>-<repo>."
  type        = string
  default     = null
}

variable "subjects" {
  description = <<-EOT
    OIDC subject suffixes allowed to assume the role, matched exactly after
    "repo:<github_account>/<repo>:". Examples: "environment:production",
    "ref:refs/heads/main". Empty keeps the default: the main branch only.
  EOT
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for s in var.subjects : !strcontains(s, "*")])
    error_message = "Subjects must not contain wildcards."
  }
}

variable "create_oidc_provider" {
  description = "Create the account's GitHub OIDC provider. Set true in exactly one place per account; elsewhere the existing provider is looked up."
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "ARN of an existing GitHub OIDC provider. Skips the lookup; useful when the provider is created in the same apply."
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "Managed policies to attach to the role."
  type        = list(string)
  default     = []
}

variable "inline_policy_json" {
  description = "Optional inline policy document (JSON) for the role."
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds."
  type        = number
  default     = 3600
}
