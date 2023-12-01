variable "runtime" {
  type = string
}

variable "function_name" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "dynamodb_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
