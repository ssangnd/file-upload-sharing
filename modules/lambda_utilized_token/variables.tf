variable "function_name" {
  type = string
}

variable "runtime" {
  type = string
}

variable "dynamodb_name" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "api_gw_trigger_lambda_utilized_execution_arn" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "s3_bucket_name" {
  type = string
}