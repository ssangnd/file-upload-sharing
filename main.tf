module "dynamodb" {
  source           = "./modules/dynamodb"
  name             = var.dynamodb_name
  billing_mode     = var.billing_mode
  read_capacity    = var.read_capacity
  write_capacity   = var.write_capacity
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type
  tags             = var.tags
}

module "api_gw" {
  source                   = "./modules/api_gw"
  lambda_initiate_upload_handler_invoke_arn = module.lambda_initiate_upload_handler.lambda_initiate_upload_handler_invoke_arn
  tags                     = var.tags
}

module "lambda_initiate_upload_handler" {
  source               = "./modules/lambda_initiate_upload_handler"
  function_name        = var.lambda_initiate_upload_handler
  runtime              = var.python_version
  dynamodb_name        = var.dynamodb_name
  region               = var.region
  account_id           = var.account_id
  api_gw_execution_arn = module.api_gw.api_gw_execution_arn
  tags                 = var.tags
}

module "lambda_post_upload_handler" {
  source = "./modules/lambda_post_upload_handler"
  function_name = var.lambda_post_upload_handler
  runtime              = var.python_version
  dynamodb_name        = var.dynamodb_name
  region               = var.region
  account_id           = var.account_id
  tags                 = var.tags
  bucket_arn = module.s3.bucket_arn
}

module "s3" {
  source         = "./modules/s3"
  s3_bucket_name = var.s3_bucket_name
  tags           = var.tags
  lambda_post_upload_handler_arn= module.lambda_post_upload_handler.lambda_post_upload_handler_arn
}

module "api_gw_lambda_utilized_token" {
  source                   = "./modules/api_gw_lambda_utilized_token"
  lambda_utilized_token_invoke_arn  = module.lambda_utilized_token.lambda_utilized_token_invoke_arn
  tags                     = var.tags
}

module "lambda_utilized_token" {
  source = "./modules/lambda_utilized_token"
  function_name        = var.lambda_utilized_token
  runtime              = var.python_version
  dynamodb_name        = var.dynamodb_name
  region               = var.region
  account_id           = var.account_id
  s3_bucket_name      = var.s3_bucket_name
  api_gw_trigger_lambda_utilized_execution_arn = module.api_gw_lambda_utilized_token.api_gw_execution_arn
  tags                 = var.tags  
}

module "cloudfront_upload" {
  source = "./modules/cloudfront_upload"
  s3_bucket_name  = var.s3_bucket_name
  region          = var.region
  account_id      = var.account_id

  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  bucket_id                   = module.s3.bucket_id
  bucket_arn                  = module.s3.bucket_arn

  api_gw_id                                = module.api_gw.api_gw_id
  api_gw_api_endpoint                      = module.api_gw.api_gw_api_endpoint
#   lambda_edge_validate_token_qualified_arn = module.lambda_edge_validate_token.lambda_edge_validate_token_qualified_arn
  depends_on                               = [module.s3, module.api_gw]
  tags = var.tags
}

module "cloudfront_download" {
  source = "./modules/cloudfront_download"
  s3_bucket_name  = var.s3_bucket_name
  region          = var.region
  account_id      = var.account_id

  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  bucket_id                   = module.s3.bucket_id
  bucket_arn                  = module.s3.bucket_arn
  api_gw_id                                = module.api_gw_lambda_utilized_token.api_gw_id
  api_gw_api_endpoint                      = module.api_gw_lambda_utilized_token.api_gw_api_endpoint
#   lambda_edge_validate_token_qualified_arn = module.lambda_edge_validate_token.lambda_edge_validate_token_qualified_arn
  depends_on                               = [module.s3, module.api_gw_lambda_utilized_token]
  tags = var.tags
}