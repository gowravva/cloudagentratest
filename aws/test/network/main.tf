resource "aws_s3_bucket" "bk123_test" {
  bucket        = "bk123-test"
  force_destroy = false

  tags = {
    Name  = "bk123-test"
    Stack = "network"
  }
}

resource "aws_s3_bucket_public_access_block" "bk123_test_public_access_block" {
  bucket = aws_s3_bucket.bk123_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "bk123_test_ownership" {
  bucket = aws_s3_bucket.bk123_test.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.bk123_test_public_access_block]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk123_test_sse" {
  bucket = aws_s3_bucket.bk123_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "bk123_test_versioning" {
  bucket = aws_s3_bucket.bk123_test.id

  versioning_configuration {
    status = "Disabled"
  }
}

output "bk123_test_bucket_id" {
  description = "The name (ID) of the bk123-test S3 bucket"
  value       = aws_s3_bucket.bk123_test.id
}

output "bk123_test_bucket_arn" {
  description = "The ARN of the bk123-test S3 bucket"
  value       = aws_s3_bucket.bk123_test.arn
}

output "bk123_test_bucket_region" {
  description = "The AWS region where the bk123-test bucket resides"
  value       = aws_s3_bucket.bk123_test.region
}

resource "aws_s3_bucket" "bk12_test" {
  bucket        = "bk12-test"
  force_destroy = false

  tags = {
    Name  = "bk12-test"
    Stack = "network"
  }
}

resource "aws_s3_bucket_public_access_block" "bk12_test_public_access_block" {
  bucket = aws_s3_bucket.bk12_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk12_test_sse" {
  bucket = aws_s3_bucket.bk12_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "bk12_test_ownership" {
  bucket = aws_s3_bucket.bk12_test.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "bk12_test_versioning" {
  bucket = aws_s3_bucket.bk12_test.id

  versioning_configuration {
    status = "Disabled"
  }
}
