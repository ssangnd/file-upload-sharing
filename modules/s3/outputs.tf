output "bucket_arn" {
  value = aws_s3_bucket.s3bucketfileuploadsharing.arn
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.s3bucketfileuploadsharing.bucket_regional_domain_name
}

output "bucket_id" {
  value = aws_s3_bucket.s3bucketfileuploadsharing.id
}