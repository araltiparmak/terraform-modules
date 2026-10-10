variable "name_prefix" {
  description = "Prefix for resource names, e.g. app-prod"
  type        = string
}

variable "google_client_id" {
  description = "Google OAuth client id (Google Cloud Console)"
  type        = string
}

variable "google_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  sensitive   = true
}

variable "callback_urls" {
  description = "Allowed OAuth callback URLs (frontend origins)"
  type        = list(string)
}

variable "logout_urls" {
  description = "Allowed sign-out redirect URLs"
  type        = list(string)
}

variable "id_token_validity_hours" {
  type    = number
  default = 1
}

variable "refresh_token_validity_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
