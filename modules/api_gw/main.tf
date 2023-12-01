/* Define Http API GW */
resource "aws_apigatewayv2_api" "agw_trigger_lambda_initiate_upload_handler" {
  name          = "agw_trigger_lambda_initiate_upload_handler"
  protocol_type = "HTTP"
  tags = var.tags
}

resource "aws_apigatewayv2_integration" "api_integration" {
  api_id                 = aws_apigatewayv2_api.agw_trigger_lambda_initiate_upload_handler.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = var.lambda_initiate_upload_handler_invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.agw_trigger_lambda_initiate_upload_handler.id
  route_key = "POST /api/items"
  target = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_deploy_stage" {
  api_id      = aws_apigatewayv2_api.agw_trigger_lambda_initiate_upload_handler.id
  auto_deploy = true
  name        = "dev"
  tags = var.tags
}