# Repository settings kept as code: squash-only merges, branch cleanup, a
# ruleset on the default branch, least-privilege workflow token and
# environments.

resource "github_repository" "this" {
  name         = var.name
  description  = var.description
  visibility   = var.visibility
  topics       = var.topics
  homepage_url = var.homepage_url

  has_issues   = var.has_issues
  has_wiki     = false
  has_projects = false

  allow_squash_merge     = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_auto_merge       = true
  delete_branch_on_merge = true

  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"

  # `terraform destroy` archives instead of deleting.
  archive_on_destroy = true
}

resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.this.name
  enabled    = true
}

resource "github_repository_ruleset" "default_branch" {
  count = var.protect_default_branch ? 1 : 0

  name        = "protect-${var.default_branch}"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/${var.default_branch}"]
      exclude = []
    }
  }

  dynamic "bypass_actors" {
    for_each = var.admin_can_bypass ? [1] : []

    content {
      actor_id    = 5 # repository admin role
      actor_type  = "RepositoryRole"
      bypass_mode = "always"
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true

    pull_request {
      required_approving_review_count = var.required_approving_review_count
      dismiss_stale_reviews_on_push   = true
    }

    dynamic "required_status_checks" {
      for_each = length(var.required_status_checks) > 0 ? [1] : []

      content {
        dynamic "required_check" {
          for_each = var.required_status_checks

          content {
            context = required_check.value
          }
        }
      }
    }
  }
}

resource "github_actions_repository_permissions" "this" {
  repository      = github_repository.this.name
  enabled         = true
  allowed_actions = var.allowed_actions

  dynamic "allowed_actions_config" {
    for_each = var.allowed_actions == "selected" ? [1] : []

    content {
      github_owned_allowed = true
      verified_allowed     = true
    }
  }
}

resource "github_workflow_repository_permissions" "this" {
  repository                       = github_repository.this.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}

resource "github_repository_environment" "this" {
  for_each = toset(var.environments)

  repository  = github_repository.this.name
  environment = each.value
}
