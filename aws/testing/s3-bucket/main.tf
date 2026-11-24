resource "aws_s3_bucket" "cost_bucket01" {
  bucket        = "cost-bucket01"
  force_destroy = true

  tags = {
    Name  = "cost-bucket01"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_versioning" "cost_bucket01_versioning" {
  bucket = aws_s3_bucket.cost_bucket01.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cost_bucket01_sse" {
  bucket = aws_s3_bucket.cost_bucket01.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cost_bucket01_pab" {
  bucket = aws_s3_bucket.cost_bucket01.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cost_bucket01_ownership" {
  bucket = aws_s3_bucket.cost_bucket01.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}