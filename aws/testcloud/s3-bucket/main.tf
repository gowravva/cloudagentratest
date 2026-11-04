resource "aws_s3_bucket_server_side_encryption_configuration" "testbucket_cloud01_sse" {
  bucket = "testbucket-cloud01"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "testbucket_cloud01_public_access_block" {
  bucket = "testbucket-cloud01"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.testbucket_cloud01_sse]
}

resource "aws_s3_bucket" "testbucket_cloud01" {
  bucket        = "testbucket-cloud01"
  force_destroy = false

  tags = {
    ManagedBy = "cloud-agentra"
    Stack     = "s3-bucket"
  }

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.testbucket_cloud01_sse,
    aws_s3_bucket_public_access_block.testbucket_cloud01_public_access_block,
  ]
}