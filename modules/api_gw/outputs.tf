output "api_gw_execution_arn" {
  value = aws_apigatewayv2_api.agw_trigger_lambda_initiate_upload_handler.execution_arn
}

output "api_gw_id" {
  value = aws_apigatewayv2_api.agw_trigger_lambda_initiate_upload_handler.id
}

output "api_gw_api_endpoint" {
  value = aws_apigatewayv2_api.agw_trigger_lambda_initiate_upload_handler.api_endpoint
}
