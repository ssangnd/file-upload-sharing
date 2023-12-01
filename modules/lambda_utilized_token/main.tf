data "aws_caller_identity" "current" {}

data "archive_file" "LambdaZipFile" {
  type        = "zip"
  source_file = "${path.module}/../../data/lambda_initiate_upload_handler/lambda_initiate_upload_handler.py"
  output_path = "${path.module}/../../data/lambda_initiate_upload_handler/lambda_initiate_upload_handler.zip"
}

resource "aws_lambda_function" "lambda_utilized_token" {
  function_name = var.function_name
  filename      = data.archive_file.LambdaZipFile.output_path
  handler       = "${var.function_name}.lambda_handler"
  runtime = var.runtime
  source_code_hash = filebase64sha256(data.archive_file.LambdaZipFile.output_path)
  role = aws_iam_role.iam_role_lambda_utilized_token_dynamodb.arn

  tags = var.tags
}

resource "aws_iam_role_policy" "iam_policy_lambda_utilized_token_dynamodb" {
  name = "iam_policy_lambda_utilized_token_dynamodb"
  role = aws_iam_role.iam_role_lambda_utilized_token_dynamodb.id

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
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.lambda_utilized_token.function_name}:*"
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
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        "Resource" : [
           "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "iam_role_lambda_utilized_token_dynamodb" {
  name = "iam_role_lambda_utilized_token_dynamodb"

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

resource "aws_lambda_permission" "apigw_lambda_utilized_token" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gw_trigger_lambda_utilized_execution_arn}/*/POST/api/items"
}
