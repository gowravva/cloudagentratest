resource "aws_s3_bucket" "mycloud_testbk789" {
  bucket        = "mycloud-testbk789"
  force_destroy = false

  tags = {
    Name  = "mycloud-testbk789"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "mycloud_testbk789_public_access_block" {
  bucket = aws_s3_bucket.mycloud_testbk789.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "mycloud_testbk789_ownership_controls" {
  bucket = aws_s3_bucket.mycloud_testbk789.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.mycloud_testbk789_public_access_block]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mycloud_testbk789_sse" {
  bucket = aws_s3_bucket.mycloud_testbk789.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "mycloud_testbk789_versioning" {
  bucket = aws_s3_bucket.mycloud_testbk789.id

  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket" "testbucket789" {
  bucket        = "testbucket789"
  force_destroy = true

  tags = {
    Name  = "testbucket789"
    Stack = "s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "testbucket789_public_access_block" {
  bucket = aws_s3_bucket.testbucket789.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "testbucket789_ownership_controls" {
  bucket = aws_s3_bucket.testbucket789.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.testbucket789_public_access_block]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "testbucket789_sse" {
  bucket = aws_s3_bucket.testbucket789.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "testbucket789_versioning" {
  bucket = aws_s3_bucket.testbucket789.id

  versioning_configuration {
    status = "Disabled"
  }
}

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
