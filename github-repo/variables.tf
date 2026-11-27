variable "name" {
  description = "Repository name"
  type        = string
}

variable "description" {
  description = "Repository description"
  type        = string
  default     = ""
}

variable "visibility" {
  description = "public, private or internal"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "visibility must be public, private or internal."
  }
}

variable "topics" {
  description = "Repository topics"
  type        = list(string)
  default     = []
}

variable "homepage_url" {
  description = "Repository homepage"
  type        = string
  default     = null
}

variable "has_issues" {
  description = "Enable issues"
  type        = bool
  default     = true
}

variable "default_branch" {
  description = "Default branch. The ruleset protects it."
  type        = string
  default     = "main"
}

variable "protect_default_branch" {
  description = "Create a ruleset for the default branch: no deletion, no force push, changes only through pull requests."
  type        = bool
  default     = true
}

variable "required_approving_review_count" {
  description = "Approvals needed before a pull request can merge. 0 still requires a pull request."
  type        = number
  default     = 0
}

variable "required_status_checks" {
  description = "Status check names (workflow job names) that must pass before merge"
  type        = list(string)
  default     = []
}

variable "admin_can_bypass" {
  description = "Let repository admins bypass the ruleset"
  type        = bool
  default     = false
}

variable "allowed_actions" {
  description = "all, local_only or selected. selected allows GitHub-owned and verified creators."
  type        = string
  default     = "selected"

  validation {
    condition     = contains(["all", "local_only", "selected"], var.allowed_actions)
    error_message = "allowed_actions must be all, local_only or selected."
  }
}

variable "environments" {
  description = "GitHub environment names to create (for example the ones github-oidc subjects use)"
  type        = list(string)
  default     = []
}
