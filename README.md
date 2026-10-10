# terraform-modules

Reusable Terraform modules. Pin a release tag when you use one:

```hcl
module "x" {
  source = "github.com/araltiparmak/terraform-modules//<module>?ref=v1.3.0"
}
```

## Releases

A commit on `main` creates a tag and a GitHub release only when its message
contains a marker. With squash merges, put the marker in the pull request
title or body:

| Marker | Result (previous `v1.3.0`) |
|---|---|
| `[release patch]` | `v1.3.1` |
| `[release minor]` | `v1.4.0` |
| `[release major]` | `v2.0.0` |
| `[release v1.5.0]` | `v1.5.0` |

No marker, no release. Use `major` for breaking changes (renamed module,
removed variable). The release notes are generated from the merged pull
requests.

## Modules

### `static-site`

S3 bucket with an optional CloudFront distribution. By default the bucket is a
public S3 website (v1 behaviour). Two opt-in flags, both need
`with_cloudfront = true`:

- `private_bucket = true`: the bucket stays private and only CloudFront reads
  it (OAC).
- `spa_mode = true`: unknown paths (403/404) return `index.html` with status
  200, so client-side routing (React, Vue, ...) survives a page refresh.

```hcl
module "app" {
  source = "github.com/araltiparmak/terraform-modules//static-site?ref=v1.3.0"

  domain_name         = "app.example.com"
  with_cloudfront     = true
  private_bucket      = true
  spa_mode            = true
  cloudfront_aliases  = ["app.example.com"]
  acm_certificate_arn = aws_acm_certificate.app.arn # us-east-1
}
```

Without `acm_certificate_arn` the default `*.cloudfront.net` certificate is
used. Outputs: `url`, `bucket_name`, `bucket_arn`, `distribution_id`,
`cloudfront_domain_name`.

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

### `lambda`

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
