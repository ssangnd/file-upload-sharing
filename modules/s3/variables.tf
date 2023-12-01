variable "s3_bucket_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "lambda_post_upload_handler_arn" {
  type = string
}