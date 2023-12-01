variable "s3_bucket_name" {
  type = string
}

variable "region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "bucket_regional_domain_name" {
  type = string
}

variable "bucket_id" {
  type = string
}

variable "bucket_arn" {
  type = string
}

variable "api_gw_id" {
  type = string
}

variable "api_gw_api_endpoint" {
  type = string
}

# variable "lambda_edge_validate_token_qualified_arn" {
#   type = string
# }

variable "tags" {
  type = map(string)
}