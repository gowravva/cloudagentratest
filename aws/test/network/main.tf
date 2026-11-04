resource "aws_s3_bucket" "testcloud_bucket" {
  bucket        = "testcloud-bucket"
  force_destroy = false

  tags = {
    Name       = "testcloud-bucket"
    ManagedBy  = "opentofu"
    Stack      = "network"
  }
}

resource "aws_s3_bucket_public_access_block" "testcloud_bucket_public_access_block" {
  bucket = aws_s3_bucket.testcloud_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "testcloud_bucket_ownership" {
  bucket = aws_s3_bucket.testcloud_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "testcloud_bucket_sse" {
  bucket = aws_s3_bucket.testcloud_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "testcloud_bucket_versioning" {
  bucket = aws_s3_bucket.testcloud_bucket.id

  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket_ownership_controls.testcloud_bucket_ownership]
}

output "testcloud_bucket_id" {
  description = "The name (ID) of the testcloud-bucket S3 bucket."
  value       = aws_s3_bucket.testcloud_bucket.id
}

output "testcloud_bucket_arn" {
  description = "The ARN of the testcloud-bucket S3 bucket."
  value       = aws_s3_bucket.testcloud_bucket.arn
}

output "testcloud_bucket_region" {
  description = "The AWS region where testcloud-bucket was created."
  value       = aws_s3_bucket.testcloud_bucket.region
}

resource "aws_s3_bucket_versioning" "bk123_test_versioning" {
  bucket = "bk123-test"

  versioning_configuration {
    status = "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bk123_test_sse" {
  bucket = "bk123-test"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bk123_test_public_access_block" {
  bucket = "bk123-test"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "bk123_test_ownership" {
  bucket = "bk123-test"

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket" "bk123_test" {
  bucket = "bk123-test"

  # force_destroy = false (original setting preserved).
  # The bucket MUST be empty before destroy will succeed.
  # If objects exist, AWS will reject the delete - empty the bucket first.
  force_destroy = false

  depends_on = [
    aws_s3_bucket_versioning.bk123_test_versioning,
    aws_s3_bucket_server_side_encryption_configuration.bk123_test_sse,
    aws_s3_bucket_public_access_block.bk123_test_public_access_block,
    aws_s3_bucket_ownership_controls.bk123_test_ownership,
  ]
}
