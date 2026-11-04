# -----------------------------------------------------------------------
# TARGETED DESTROY - bk123-test bucket and its 4 configuration resources
# The sibling bucket bk12-test and all its resources are NOT represented
# here and will remain completely untouched.
#
# The host runner will execute:
#   tofu destroy \
#     -target=aws_s3_bucket_versioning.bk123_test_versioning \
#     -target=aws_s3_bucket_server_side_encryption_configuration.bk123_test_sse \
#     -target=aws_s3_bucket_public_access_block.bk123_test_public_access_block \
#     -target=aws_s3_bucket_ownership_controls.bk123_test_ownership \
#     -target=aws_s3_bucket.bk123_test
#
# WARNING: force_destroy = false - if the bucket contains any objects
# AWS will reject the delete. Empty the bucket manually first.
# -----------------------------------------------------------------------

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