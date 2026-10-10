data "archive_file" "package" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.root}/.artifacts/${var.function_name}.zip"
}

resource "aws_iam_role" "this" {
  name                 = var.function_name
  permissions_boundary = var.permissions_boundary_arn
  tags                 = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "inline" {
  count = var.inline_policy_json == null ? 0 : 1

  name   = "app-access"
  role   = aws_iam_role.this.id
  policy = var.inline_policy_json
}

# Managed here so logs expire; Lambda would otherwise create it with no
# retention.
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.this.arn
  runtime       = var.runtime
  architectures = var.architectures
  handler       = var.handler
  memory_size   = var.memory_size
  timeout       = var.timeout
  tags          = var.tags

  filename         = data.archive_file.package.output_path
  source_code_hash = data.archive_file.package.output_base64sha256

  ephemeral_storage {
    size = var.ephemeral_storage_mb
  }

  dynamic "environment" {
    for_each = length(var.environment) > 0 ? [1] : []
    content {
      variables = var.environment
    }
  }

  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.this.name
  }

  depends_on = [aws_iam_role_policy_attachment.logs]
}

resource "aws_lambda_function_event_invoke_config" "this" {
  count = var.async_max_retry_attempts == null ? 0 : 1

  function_name          = aws_lambda_function.this.function_name
  maximum_retry_attempts = var.async_max_retry_attempts
}
