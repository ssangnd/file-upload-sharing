# Resource Block: Create AWS S3 Bucket
resource "aws_s3_bucket" "s3bucketfileuploadsharing" {
  bucket = var.s3_bucket_name
  tags = var.tags
}

resource "aws_s3_object" "content" {
  bucket                 = aws_s3_bucket.s3bucketfileuploadsharing.bucket
  key                    = "index.html"
  source                 = "./index.html"
  server_side_encryption = "AES256"
  content_type           = "text/html"
  
  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "s3bucketfileuploadsharing" {
  bucket = aws_s3_bucket.s3bucketfileuploadsharing.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_versioning" "s3bucketfileuploadsharing_versioning" {
  bucket = aws_s3_bucket.s3bucketfileuploadsharing.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.s3bucketfileuploadsharing.id

  lambda_function {
    lambda_function_arn = var.lambda_post_upload_handler_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "AWSLogs/"
    filter_suffix       = ".log"
  }
}