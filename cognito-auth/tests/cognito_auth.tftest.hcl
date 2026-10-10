mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = { account_id = "123456789012" }
  }
}

variables {
  name_prefix          = "app-prod"
  google_client_id     = "id"
  google_client_secret = "secret"
  callback_urls        = ["https://example.cloudfront.net/"]
  logout_urls          = ["https://example.cloudfront.net/"]
}

run "google_only_code_flow" {
  command = plan

  assert {
    condition     = aws_cognito_user_pool_client.spa.supported_identity_providers == toset(["Google"])
    error_message = "Only Google sign-in is allowed."
  }

  assert {
    condition     = aws_cognito_user_pool_client.spa.generate_secret == false
    error_message = "A browser client cannot keep a secret."
  }

  assert {
    condition     = aws_cognito_user_pool_domain.this.domain == "app-prod-123456789012"
    error_message = "Domain must be unique per account."
  }
}
