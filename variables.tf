variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "python_version" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "dynamodb_name" {
  type = string
}

variable "billing_mode" {
  type = string
}

variable "read_capacity" {
  type = number
}

variable "write_capacity" {
  type = number
}

variable "stream_enabled" {
  type = bool
}

variable "stream_view_type" {
  type = string
}

# lambda
variable "lambda_initiate_upload_handler" {
  type = string
}

variable "lambda_post_upload_handler" {
  type = string
}

variable "lambda_utilized_token" {
  type = string
}


variable "s3_bucket_name" {
  type = string
}