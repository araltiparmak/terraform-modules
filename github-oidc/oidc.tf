locals {
  role_name = coalesce(var.role_name, "github-actions-${var.github_account}-${var.repo}")

  # Default keeps the v1.1 behaviour: only the main branch may assume the role.
  subjects = (
    length(var.subjects) > 0
    ? [for s in var.subjects : "repo:${var.github_account}/${var.repo}:${s}"]
    : ["repo:${var.github_account}/${var.repo}:ref:refs/heads/main"]
  )

  oidc_provider_arn = (
    var.create_oidc_provider
    ? aws_iam_openid_connect_provider.this[0].arn
    : coalesce(var.oidc_provider_arn, one(data.aws_iam_openid_connect_provider.this[*].arn))
  )
}

# An account has at most one GitHub OIDC provider. Create it in exactly one
# place; elsewhere pass its ARN or let the module look it up.
resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # AWS no longer checks these for GitHub, but older provider versions
  # require the argument.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

data "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider || var.oidc_provider_arn != null ? 0 : 1

  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    # StringEquals, not StringLike: no wildcards, so a new branch or workflow
    # can never match by accident.
    condition {
      test     = "StringEquals"
      values   = local.subjects
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = local.role_name
  assume_role_policy   = data.aws_iam_policy_document.oidc.json
  max_session_duration = var.max_session_duration
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  count = var.inline_policy_json == null ? 0 : 1

  name   = "deploy"
  role   = aws_iam_role.this.id
  policy = var.inline_policy_json
}
