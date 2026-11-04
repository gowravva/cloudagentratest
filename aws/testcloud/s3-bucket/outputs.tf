output "gowritest_001_bucket_id" {
  description = "ID of the gowritest-001 S3 bucket (will be empty after destroy)"
  value       = aws_s3_bucket.gowritest_001.id
}

output "gowritest_001_bucket_arn" {
  description = "ARN of the gowritest-001 S3 bucket (will be empty after destroy)"
  value       = aws_s3_bucket.gowritest_001.arn
}