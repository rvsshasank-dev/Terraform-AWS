provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "eks_bucket" {
  bucket = "my-eks-bucket"

  lifecycle {
    prevent_destroy = false
  }
}
resource "aws_dynamodb_table" "eks_table" {
  name         = "terraform-eks-statelocks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Lockid"

  attribute {
    name = "Lockid"
    type = "S"
  }

  tags = {
    Name        = "eksTable"
    Environment = "Dev"
  }
}