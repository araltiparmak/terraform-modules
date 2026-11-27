mock_provider "github" {}

variables {
  name = "postpilot"
}

run "secure_defaults" {
  command = plan

  assert {
    condition = (
      github_repository.this.allow_squash_merge
      && !github_repository.this.allow_merge_commit
      && !github_repository.this.allow_rebase_merge
      && github_repository.this.delete_branch_on_merge
    )
    error_message = "Only squash merges are allowed and merged branches are deleted."
  }

  assert {
    condition     = github_repository.this.visibility == "private"
    error_message = "Repositories are private by default."
  }

  assert {
    condition     = github_workflow_repository_permissions.this.default_workflow_permissions == "read"
    error_message = "The workflow token must be read-only by default."
  }

  assert {
    condition     = length(github_repository_ruleset.default_branch) == 1
    error_message = "The default branch must be protected by default."
  }
}

run "status_checks_and_environments" {
  command = plan

  variables {
    required_status_checks = ["modules"]
    environments           = ["dev", "prod"]
  }

  assert {
    condition     = length(github_repository_environment.this) == 2
    error_message = "One environment per name."
  }
}

run "rejects_bad_visibility" {
  command = plan

  variables {
    visibility = "everyone"
  }

  expect_failures = [var.visibility]
}
