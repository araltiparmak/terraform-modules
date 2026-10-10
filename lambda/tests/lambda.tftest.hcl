mock_provider "aws" {}

variables {
  function_name = "app-prod-api"
  source_dir    = "tests/fixture"
}

run "defaults" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.this.name == "/aws/lambda/app-prod-api"
    error_message = "Log group must follow the Lambda naming convention."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.retention_in_days == 30
    error_message = "Logs should expire after 30 days by default."
  }

  assert {
    condition     = length(aws_lambda_function_event_invoke_config.this) == 0
    error_message = "No invoke config unless retries are set."
  }

  assert {
    condition     = length(aws_iam_role_policy.inline) == 0
    error_message = "No inline policy by default."
  }

  assert {
    condition     = aws_lambda_function.this.architectures == tolist(["arm64"])
    error_message = "arm64 is the default architecture."
  }
}

run "async_no_retries_and_boundary" {
  command = plan

  variables {
    async_max_retry_attempts = 0
    permissions_boundary_arn = "arn:aws:iam::123456789012:policy/app-prod-boundary"
    inline_policy_json       = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
  }

  assert {
    condition     = aws_lambda_function_event_invoke_config.this[0].maximum_retry_attempts == 0
    error_message = "Retries must be switched off."
  }

  assert {
    condition     = aws_iam_role.this.permissions_boundary == "arn:aws:iam::123456789012:policy/app-prod-boundary"
    error_message = "The role must carry the boundary."
  }

  assert {
    condition     = length(aws_iam_role_policy.inline) == 1
    error_message = "Inline policy missing."
  }
}

run "rejects_too_many_retries" {
  command = plan

  variables {
    async_max_retry_attempts = 5
  }

  expect_failures = [var.async_max_retry_attempts]
}
