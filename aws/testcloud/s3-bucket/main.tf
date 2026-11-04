# Destroy scope: gowritest-001 and its two configuration resources only.
# testbucket-cloud01 and all its sibling resources are intentionally preserved.

# ---------------------------------------------------------------------------
# gowritest-001 - SSE configuration (destroyed first)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "gowritest_001_sse" {
  bucket = aws_s3_bucket.gowritest_001.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------------------------------------------------------------------
# gowritest-001 - Public access block (destroyed before bucket)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket_public_access_block" "gowritest_001_public_access_block" {
  bucket = aws_s3_bucket.gowritest_001.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_server_side_encryption_configuration.gowritest_001_sse]
}

# ---------------------------------------------------------------------------
# gowritest-001 - The bucket itself (destroyed last)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "gowritest_001" {
  bucket        = "gowritest-001"
  force_destroy = false

  tags = {
    stack = "s3-bucket"
    name  = "gowritest-001"
  }

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.gowritest_001_sse,
    aws_s3_bucket_public_access_block.gowritest_001_public_access_block,
  ]
}