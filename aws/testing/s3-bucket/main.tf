resource "aws_s3_bucket" "testcloudagentra_prod98" {
  bucket        = "testcloudagentra-prod98"
  force_destroy = true

  tags = {
    Name  = "testcloudagentra-prod98"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "testcloudagentra_prod98_ownership" {
  bucket = aws_s3_bucket.testcloudagentra_prod98.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket.testcloudagentra_prod98]
}

resource "aws_s3_bucket_public_access_block" "testcloudagentra_prod98_pab" {
  bucket = aws_s3_bucket.testcloudagentra_prod98.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.testcloudagentra_prod98,
    aws_s3_bucket_ownership_controls.testcloudagentra_prod98_ownership,
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "testcloudagentra_prod98_sse" {
  bucket = aws_s3_bucket.testcloudagentra_prod98.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [aws_s3_bucket.testcloudagentra_prod98]
}

resource "aws_s3_bucket_versioning" "testcloudagentra_prod98_versioning" {
  bucket = aws_s3_bucket.testcloudagentra_prod98.id

  versioning_configuration {
    status = "Disabled"
  }

  depends_on = [aws_s3_bucket.testcloudagentra_prod98]
}