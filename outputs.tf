###############################################################################
# outputs.tf
###############################################################################

output "bucket_name" {
  description = "Name of the demo S3 bucket"
  value       = module.demo_bucket.bucket_name
}

output "bucket_arn" {
  description = "ARN of the demo S3 bucket"
  value       = module.demo_bucket.bucket_arn
}

output "bucket_region" {
  description = "Region where the bucket was created"
  value       = var.aws_region
}
