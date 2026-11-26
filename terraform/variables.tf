
variable "aws_region" {
  description = "AWS region where infrastructure will be configured"
  type        = string
  default     = "us-west-2"
}

variable "s3_bucket_name" {
  description = "Name of the secure S3 bucket"
  type        = string
  default     = "secure-cloud-infrastructure-portfolio-change-me"
}

