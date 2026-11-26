
output "vpc_id" {
  description = "ID of the secure VPC"
  value       = aws_vpc.secure_vpc.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "ID of the restrictive security group"
  value       = aws_security_group.secure_sg.id
}




output "s3_bucket_name" {
  description = "Name of the secure S3 bucket"
  value       = aws_s3_bucket.secure_storage.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the secure S3 bucket"
  value       = aws_s3_bucket.secure_storage.arn
}
