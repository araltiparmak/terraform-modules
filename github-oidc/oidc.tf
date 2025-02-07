data "aws_iam_openid_connect_provider" "this" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      values   = ["repo:${var.github_account}/${var.repo}:ref:refs/heads/main"]
      variable = "token.actions.githubusercontent.com:sub"
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = "github-actions-${var.github_account}-${var.repo}"
  assume_role_policy   = data.aws_iam_policy_document.oidc.json
  max_session_duration = 3600
}