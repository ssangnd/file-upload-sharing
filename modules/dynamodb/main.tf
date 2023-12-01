resource "aws_dynamodb_table" "dynamodb_table_ssl" {
  name             = var.name
  billing_mode     = var.billing_mode
  read_capacity    = var.read_capacity
  write_capacity   = var.write_capacity
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

   hash_key         = "id"
   attribute {
    name = "id"
    type = "N"
  }

  tags = var.tags
}