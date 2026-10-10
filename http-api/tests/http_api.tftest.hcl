mock_provider "aws" {}

variables {
  name                 = "app-prod-api"
  routes               = ["GET /me", "POST /posts", "GET /posts/{id}"]
  lambda_invoke_arn    = "arn:aws:apigateway:eu-central-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-central-1:123456789012:function:app/invocations"
  lambda_function_name = "app"
  jwt_issuer           = "https://cognito-idp.eu-central-1.amazonaws.com/pool"
  jwt_audience         = ["client"]
  cors_allow_origins   = ["https://example.cloudfront.net"]
}

run "routes_behind_jwt" {
  command = plan

  assert {
    condition     = length(aws_apigatewayv2_route.this) == 3
    error_message = "One route per key."
  }

  assert {
    condition     = alltrue([for r in aws_apigatewayv2_route.this : r.authorization_type == "JWT"])
    error_message = "Every route must require a JWT."
  }

  assert {
    condition     = aws_apigatewayv2_api.this.cors_configuration[0].allow_origins == toset(["https://example.cloudfront.net"])
    error_message = "CORS origins not applied."
  }
}
