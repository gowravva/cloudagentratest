resource "aws_s3_bucket" "testgowri_s31" {
  bucket        = "testgowri-s31"
  force_destroy = true

  tags = {
    Name  = "testgowri-s31"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_versioning" "testgowri_s31_versioning" {
  bucket = aws_s3_bucket.testgowri_s31.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "testgowri_s31_public_access_block" {
  bucket = aws_s3_bucket.testgowri_s31.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "testgowri_s31_sse" {
  bucket = aws_s3_bucket.testgowri_s31.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}