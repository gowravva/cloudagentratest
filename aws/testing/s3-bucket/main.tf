resource "aws_s3_bucket" "testprodbk_tb001" {
  bucket = "testprodbk-tb001"

  tags = {
    Name  = "testprodbk-tb001"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "testprodbk_tb001_ownership" {
  bucket = aws_s3_bucket.testprodbk_tb001.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket.testprodbk_tb001]
}

resource "aws_s3_bucket_public_access_block" "testprodbk_tb001_pab" {
  bucket = aws_s3_bucket.testprodbk_tb001.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.testprodbk_tb001,
    aws_s3_bucket_ownership_controls.testprodbk_tb001_ownership,
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "testprodbk_tb001_sse" {
  bucket = aws_s3_bucket.testprodbk_tb001.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [aws_s3_bucket.testprodbk_tb001]
}

resource "aws_s3_bucket_versioning" "testprodbk_tb001_versioning" {
  bucket = aws_s3_bucket.testprodbk_tb001.id

  versioning_configuration {
    status = "Disabled"
  }

  depends_on = [aws_s3_bucket.testprodbk_tb001]
}