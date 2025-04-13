resource "aws_dynamodb_table" "processed_logs" {
  name           = "ProcessedLogs"
  hash_key       = "log_id"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "log_id"
    type = "S"
  }
}
