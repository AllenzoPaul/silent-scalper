resource "aws_dynamodb_table" "processed_data" {
  name         = "SilentScalperData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "fileId"

  attribute {
    name = "fileId"
    type = "S"
  }
}