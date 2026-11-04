output "bucket_id" {
  description = "The name/ID of the S3 bucket."
  value       = aws_s3_bucket.testbucket_cloud01.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.testbucket_cloud01.arn
}

output "bucket_region" {
  description = "The region in which the bucket was created."
  value       = aws_s3_bucket.testbucket_cloud01.region
}