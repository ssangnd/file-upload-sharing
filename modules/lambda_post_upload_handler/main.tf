data "aws_caller_identity" "current" {}

data "archive_file" "LambdaZipFile" {
  type        = "zip"
  source_file = "${path.module}/../../data/lambda_initiate_upload_handler/lambda_initiate_upload_handler.py"
  output_path = "${path.module}/../../data/lambda_initiate_upload_handler/lambda_initiate_upload_handler.zip"
}

resource "aws_lambda_function" "lambda_post_upload_handler" {
  function_name = var.function_name
  filename      = data.archive_file.LambdaZipFile.output_path
  handler       = "${var.function_name}.lambda_handler"
  runtime = var.runtime
  source_code_hash = filebase64sha256(data.archive_file.LambdaZipFile.output_path)
  role = aws_iam_role.iam_role_lambda_post_upload_handler_dynamodb.arn

  tags = var.tags
}

resource "aws_iam_role_policy" "iam_policy_lambda_post_upload_handler_dynamodb" {
  name = "iam_policy_lambda_post_upload_handler_dynamodb"
  role = aws_iam_role.iam_role_lambda_post_upload_handler_dynamodb.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        "Resource" : [
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.lambda_post_upload_handler.function_name}:*"
          ]
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetRecords",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect = "Allow"
        "Resource" : [
          "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.dynamodb_name}"
        ]
      },
      {
        Action = [
          "ses:SendEmail"
        ]
        Effect = "Allow"
        "Resource" : [
          "arn:aws:ses:${var.region}:${var.account_id}:identity/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "iam_role_lambda_post_upload_handler_dynamodb" {
  name = "iam_role_lambda_post_upload_handler_dynamodb"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_post_upload_handler.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}