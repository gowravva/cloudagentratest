output "bucket_id" {
  description = "The name/ID of the S3 bucket."
  value       = aws_s3_bucket.bk_test11.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.bk_test11.arn
}

output "bucket_region" {
  description = "The AWS region where the bucket resides."
  value       = aws_s3_bucket.bk_test11.region
}