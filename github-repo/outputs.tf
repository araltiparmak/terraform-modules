output "name" {
  description = "Repository name"
  value       = github_repository.this.name
}

output "full_name" {
  description = "owner/name"
  value       = github_repository.this.full_name
}

output "html_url" {
  description = "Repository URL"
  value       = github_repository.this.html_url
}

output "environments" {
  description = "Environment names created"
  value       = [for e in github_repository_environment.this : e.environment]
}
