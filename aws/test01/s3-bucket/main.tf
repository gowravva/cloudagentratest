resource "aws_s3_bucket" "prodtest_aws01" {
  bucket        = "prodtest-aws01"
  force_destroy = true

  tags = {
    Name  = "prodtest-aws01"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "prodtest_aws01_public_access_block" {
  bucket = aws_s3_bucket.prodtest_aws01.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prodtest_aws01_sse" {
  bucket = aws_s3_bucket.prodtest_aws01.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

output "bucket_id" {
  description = "The name (ID) of the S3 bucket."
  value       = aws_s3_bucket.prodtest_aws01.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.prodtest_aws01.arn
}

output "bucket_region" {
  description = "The AWS region where the bucket resides."
  value       = aws_s3_bucket.prodtest_aws01.region
}