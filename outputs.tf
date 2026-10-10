output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "web_instance_id" {
  description = "ID of the web EC2 instance."
  value       = aws_instance.web.id
}

output "artifacts_bucket" {
  description = "Name of the artifacts S3 bucket."
  value       = aws_s3_bucket.artifacts.bucket
}
