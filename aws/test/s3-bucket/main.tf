resource "aws_s3_bucket" "bk_test11" {
  bucket        = "bk-test11"
  force_destroy = true

  tags = {
    Stack = "s3-bucket"
    Name  = "bk-test11"
  }
}

resource "aws_s3_bucket_public_access_block" "bk_test11_public_access_block" {
  bucket = aws_s3_bucket.bk_test11.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk_test11_sse" {
  bucket = aws_s3_bucket.bk_test11.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}