resource "aws_s3_bucket" "gowri_agentra_test_444062204915" {
  bucket        = "gowri-agentra-test-444062204915"
  force_destroy = false

  tags = {
    Name  = "gowri-agentra-test-444062204915"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "gowri_agentra_test_444062204915_public_access_block" {
  bucket = aws_s3_bucket.gowri_agentra_test_444062204915.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "gowri_agentra_test_444062204915_ownership_controls" {
  bucket = aws_s3_bucket.gowri_agentra_test_444062204915.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.gowri_agentra_test_444062204915_public_access_block]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gowri_agentra_test_444062204915_sse" {
  bucket = aws_s3_bucket.gowri_agentra_test_444062204915.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket" "agentic_b001" {
  bucket = "agentic-b001"

  tags = {
    Name  = "agentic-b001"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "agentic_b001_public_access_block" {
  bucket = aws_s3_bucket.agentic_b001.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "agentic_b001_sse" {
  bucket = aws_s3_bucket.agentic_b001.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket" "gowritest_001" {
  bucket        = "gowritest-001"
  force_destroy = false

  tags = {
    stack = "s3-bucket"
    name  = "gowritest-001"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gowritest_001_sse" {
  bucket = aws_s3_bucket.gowritest_001.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "gowritest_001_public_access_block" {
  bucket = aws_s3_bucket.gowritest_001.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.gowritest_001_sse]
}

resource "aws_s3_bucket" "gowri_agentra_test" {
  bucket        = "gowri-agentra-test-444062204915"
  force_destroy = true

  tags = {
    Name  = "gowri-agentra-test-444062204915"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "gowri_agentra_test_public_access_block" {
  bucket = aws_s3_bucket.gowri_agentra_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gowri_agentra_test_sse" {
  bucket = aws_s3_bucket.gowri_agentra_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}