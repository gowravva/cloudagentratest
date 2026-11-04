# ──────────────────────────────────────────────────────────────────────────────
# Targeted destroy - cloud-test-bucket05 and its 4 configuration resources
# Region: ap-south-1 (Mumbai)  |  Stack: network
#
# ⚠  force_destroy = false - the bucket MUST be empty before destroying.
#    If the bucket contains any objects or delete markers, AWS will reject
#    the deletion and the destroy will fail.
#
# The sibling bucket bk123-test and its resources are NOT represented here
# and will NOT be touched by this operation.
# ──────────────────────────────────────────────────────────────────────────────

# ── Dependent configuration resources (destroyed before the bucket) ───────────

resource "aws_s3_bucket_public_access_block" "cloud_test_bucket05_public_access_block" {
  bucket = "cloud-test-bucket05"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cloud_test_bucket05_ownership" {
  bucket = "cloud-test-bucket05"

  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  depends_on = [aws_s3_bucket_public_access_block.cloud_test_bucket05_public_access_block]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloud_test_bucket05_sse" {
  bucket = "cloud-test-bucket05"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [aws_s3_bucket_public_access_block.cloud_test_bucket05_public_access_block]
}

resource "aws_s3_bucket_versioning" "cloud_test_bucket05_versioning" {
  bucket = "cloud-test-bucket05"

  versioning_configuration {
    status = "Suspended"
  }

  depends_on = [aws_s3_bucket_public_access_block.cloud_test_bucket05_public_access_block]
}

# ── Primary bucket (destroyed last, after all dependents are removed) ─────────

resource "aws_s3_bucket" "cloud_test_bucket05" {
  bucket = "cloud-test-bucket05"

  # force_destroy = false (default) - destroy will hard-fail if bucket is not empty.
  # Confirm the bucket contains zero objects and zero delete markers before applying.
  force_destroy = false

  tags = {
    Name      = "cloud-test-bucket05"
    ManagedBy = "opentofu"
    Stack     = "network"
  }

  depends_on = [
    aws_s3_bucket_public_access_block.cloud_test_bucket05_public_access_block,
    aws_s3_bucket_ownership_controls.cloud_test_bucket05_ownership,
    aws_s3_bucket_server_side_encryption_configuration.cloud_test_bucket05_sse,
    aws_s3_bucket_versioning.cloud_test_bucket05_versioning,
  ]
}