resource "aws_s3_bucket" "test001" {
  bucket        = "test001"
  force_destroy = true

  tags = {
    Name  = "test001"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "test001_public_access_block" {
  bucket = aws_s3_bucket.test001.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "test001_versioning" {
  bucket = aws_s3_bucket.test001.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test001_encryption" {
  bucket = aws_s3_bucket.test001.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "bucket_id" {
  description = "The name (ID) of the S3 bucket."
  value       = aws_s3_bucket.test001.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.test001.arn
}

output "bucket_region" {
  description = "The AWS region the bucket was created in."
  value       = aws_s3_bucket.test001.region
}