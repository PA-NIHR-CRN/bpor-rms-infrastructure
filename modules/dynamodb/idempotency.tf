resource "aws_dynamodb_table" "idempotency" {
  name         = var.idempotency_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  ttl {
    attribute_name = "expiration"
    enabled        = true
  }
  tags = {
      Name             = var.idempotency_name
      Environment      = var.env
      System           = var.system
    }
}