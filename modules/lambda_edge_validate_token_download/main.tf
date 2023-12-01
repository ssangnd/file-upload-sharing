provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

### Set up IAM role and policies for the lambda
data "aws_iam_policy_document" "lambda_edge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}

# Define the IAM role for logging from the Lambda function.
data "aws_iam_policy_document" "lambda_edge_validate_token_download_logging_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      /* "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.lambda_edge_validate_token.function_name}:*" */
      "arn:aws:logs:*:*:*"
    ]   
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
       "arn:aws:s3:::${var.s3_bucket_name}",
       "arn:aws:s3:::${var.s3_bucket_name}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
       "dynamodb:PutItem",
       "dynamodb:GetRecords",
       "dynamodb:GetItem",
       "dynamodb:Scan",
       "dynamodb:Query"
    ]
    resources = [
       "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.dynamodb_name}"
    ]
  }
}

resource "aws_cloudwatch_log_group" "lambda_edge_validate_token_download_log_group" {
  name = "/aws/lambda_edge_validate_token/logs"
  retention_in_days = 14
}

# Add IAM policy for logging to the iam role
resource "aws_iam_role_policy" "lambda_edge_vdalidate_token_logging" {
  name = "aws-lambda_edge_validate_token_logging"
  role = aws_iam_role.lambda_edge_validate_token.id

  policy = data.aws_iam_policy_document.lambda_edge_validate_token_download_logging_policy.json
}

# Create the iam role for the lambda function
resource "aws_iam_role" "lambda_edge_validate_token" {
  name               = "lambda_edge_validate_token"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_assume_role.json
  tags = var.tags
}


data "archive_file" "LambdaZipFile" {
  type        = "zip"
  source_file = "${path.module}/../../data/lambda_initiate_upload_handler/lambda_initiate_upload_handler.py"
  output_path = "${path.module}/../../data/lambda_initiate_upload_handler/lambda_initiate_upload_handler.zip"
#   source_file = "${path.module}/../../data/lambda_edge_validate_token/lambda_edge_validate_token.py"
#   output_path = "${path.module}/../../data/lambda_edge_validate_token/lambda_edge_validate_token.zip"
}

resource "aws_lambda_function" "lambda_edge_validate_token" {
  function_name = var.function_name
  filename      = data.archive_file.LambdaZipFile.output_path
  handler       = "${var.function_name}.lambda_handler"
  runtime = var.runtime
  source_code_hash = filebase64sha256(data.archive_file.LambdaZipFile.output_path)
  role          = aws_iam_role.lambda_edge_validate_token.arn
  publish       = true
  timeout       = 5
  depends_on    = [
    aws_cloudwatch_log_group.lambda_edge_validate_token_download_log_group
  ]

  tags = var.tags
}
