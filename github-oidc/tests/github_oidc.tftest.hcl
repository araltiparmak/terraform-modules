# Plan-only tests with a mocked AWS provider: no credentials, nothing created.
# Run with: terraform init && terraform test

mock_provider "aws" {
  # Mocked data sources return random strings; the role needs valid JSON.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  github_account = "octo"
  repo           = "app"
}

run "defaults_keep_v1_1_behaviour" {
  command = plan

  assert {
    condition     = aws_iam_role.this.name == "github-actions-octo-app"
    error_message = "Default role name changed."
  }

  assert {
    condition = toset(flatten([
      for c in data.aws_iam_policy_document.oidc.statement[0].condition :
      c.values if c.variable == "token.actions.githubusercontent.com:sub"
    ])) == toset(["repo:octo/app:ref:refs/heads/main"])
    error_message = "Default subject must be the main branch only."
  }

  assert {
    condition     = length(aws_iam_openid_connect_provider.this) == 0
    error_message = "The OIDC provider must not be created by default."
  }

  assert {
    condition     = length(aws_iam_role_policy.inline) == 0 && length(aws_iam_role_policy_attachment.managed) == 0
    error_message = "No policies should be attached by default."
  }
}

run "environment_scoped_role" {
  command = plan

  variables {
    role_name            = "app-deploy-dev"
    subjects             = ["environment:dev"]
    create_oidc_provider = true
    inline_policy_json   = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }

  assert {
    condition = toset(flatten([
      for c in data.aws_iam_policy_document.oidc.statement[0].condition :
      c.values if c.variable == "token.actions.githubusercontent.com:sub"
    ])) == toset(["repo:octo/app:environment:dev"])
    error_message = "Subject must be scoped to the dev environment."
  }

  assert {
    condition = alltrue([
      for c in data.aws_iam_policy_document.oidc.statement[0].condition :
      c.test == "StringEquals"
    ])
    error_message = "Trust conditions must use StringEquals."
  }

  assert {
    condition     = length(aws_iam_openid_connect_provider.this) == 1
    error_message = "The OIDC provider should be created."
  }

  assert {
    condition     = aws_iam_role.this.name == "app-deploy-dev"
    error_message = "role_name was ignored."
  }

  assert {
    condition     = length(aws_iam_role_policy.inline) == 1
    error_message = "Inline policy was not attached."
  }
}

run "rejects_wildcard_subjects" {
  command = plan

  variables {
    subjects = ["ref:refs/heads/*"]
  }

  expect_failures = [var.subjects]
}

run "uses_given_provider_arn" {
  command = plan

  variables {
    oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
  }

  assert {
    condition     = length(data.aws_iam_openid_connect_provider.this) == 0
    error_message = "The provider lookup must be skipped when an ARN is given."
  }

  assert {
    condition     = output.oidc_provider_arn == var.oidc_provider_arn
    error_message = "The given provider ARN was not used."
  }
}
