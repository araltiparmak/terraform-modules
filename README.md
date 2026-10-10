# terraform-modules

Reusable Terraform modules. Pin a release tag when you use one:

```hcl
module "x" {
  source = "github.com/araltiparmak/terraform-modules//<module>?ref=v1.3.0"
}
```

## Modules

### `static-site`

S3 website bucket with an optional CloudFront distribution.

### `github-oidc`

IAM role that GitHub Actions assumes through OIDC.

```hcl
module "deploy_dev" {
  source = "github.com/araltiparmak/terraform-modules//github-oidc?ref=v1.2.0"

  github_account       = "araltiparmak"
  repo                 = "postpilot"
  role_name            = "postpilot-github-dev"
  subjects             = ["environment:dev"] # exact match, no wildcards
  oidc_provider_arn    = aws_iam_openid_connect_provider.github.arn # or create_oidc_provider = true, or omit to look it up
  inline_policy_json   = data.aws_iam_policy_document.deploy_dev.json
}
```

- `subjects` defaults to the `main` branch only (v1.1 behaviour).
- Use `environment:<name>` subjects together with GitHub environment
  protection rules. The role is then usable only by jobs in that environment.
- Outputs: `role_arn`, `role_name`, `oidc_provider_arn`.

### `spa-site`

Single-page app hosting: private S3 bucket + CloudFront (OAC), HTTPS, and
403/404 → `index.html`. Outputs `bucket_name`, `bucket_arn`, `distribution_id`,
`url`.

### `lambda-function`

Lambda with its role, log group (30-day retention), optional inline policy,
permissions boundary and async retry setting (`async_max_retry_attempts = 0`
for handlers that must not run twice). Zips `source_dir`.

### `http-api`

API Gateway HTTP API: every route goes to one Lambda behind a JWT authorizer,
with CORS and throttling.

### `cognito-auth`

Cognito user pool with Google sign-in only and a browser (code flow) client.
Outputs `authority` and `client_id` for an API JWT authorizer and the SPA.

## Development

```sh
cd <module>
terraform init -backend=false
terraform test   # plan-only tests with a mocked AWS provider
```
