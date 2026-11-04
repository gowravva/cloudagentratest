resource "aws_s3_bucket" "testbucket_cloud01" {
  bucket        = "testbucket-cloud01"
  force_destroy = false

  tags = {
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "testbucket_cloud01_public_access_block" {
  bucket = aws_s3_bucket.testbucket_cloud01.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "testbucket_cloud01_sse" {
  bucket = aws_s3_bucket.testbucket_cloud01.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}