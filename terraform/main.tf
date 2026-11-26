
# ==========================================
# 1. NETWORK FOUNDATION
# ==========================================

# Retrieve the AWS account ID for the KMS key policy.
data "aws_caller_identity" "current" {}

# Discover the specifically selected AWS Availability Zone.
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }

  filter {
    name   = "zone-name"
    values = ["us-west-2a"]
  }
}

# Create the dedicated VPC.
resource "aws_vpc" "secure_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "secure-cloud-vpc"
    Environment = "Portfolio"
  }
}

# Create the private subnet.
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.secure_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name        = "secure-private-subnet"
    Environment = "Portfolio"
  }
}

# Create the public subnet.
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.secure_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name        = "secure-public-subnet"
    Environment = "Portfolio"
  }
}

# Create a restrictive security group.
resource "aws_security_group" "secure_sg" {
  name        = "secure-cloud-security-group"
  description = "Security group with no inbound access"
  vpc_id      = aws_vpc.secure_vpc.id

  tags = {
    Name        = "secure-cloud-security-group"
    Environment = "Portfolio"
  }
}

# ==========================================
# 2. SECURE S3 STORAGE
# ==========================================

# Create the private S3 bucket.
resource "aws_s3_bucket" "secure_storage" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "secure-cloud-storage"
    Environment = "Portfolio"
  }
}

# Configure S3 lifecycle management.
resource "aws_s3_bucket_lifecycle_configuration" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id

  rule {
    id     = "manage-old-object-versions"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

# Block all public access.
resource "aws_s3_bucket_public_access_block" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable default AWS KMS encryption for S3.
resource "aws_s3_bucket_server_side_encryption_configuration" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_storage.arn
    }

    bucket_key_enabled = true
  }
}

# Enforce bucket ownership.
resource "aws_s3_bucket_ownership_controls" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Deny requests that do not use HTTPS.
resource "aws_s3_bucket_policy" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.secure_storage.arn,
          "${aws_s3_bucket.secure_storage.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.secure_storage
  ]
}


# Restrict the VPC's default security group.
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.secure_vpc.id

  ingress = []
  egress  = []

  tags = {
    Name        = "restricted-default-security-group"
    Environment = "Portfolio"
  }
}

# ==========================================
# 3. VPC NETWORK MONITORING
# ==========================================

# Create a KMS key to encrypt CloudWatch logs.
resource "aws_kms_key" "cloudwatch_logs" {
  description             = "KMS key for encrypting VPC Flow Logs"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableAccountAdministration"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsEncryption"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.aws_region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/secure-cloud-flow-logs"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "cloudwatch-logs-kms-key"
    Environment = "Portfolio"
  }
}

# Create a CloudWatch log group for VPC Flow Logs.
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/secure-cloud-flow-logs"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn

  tags = {
    Name        = "secure-vpc-flow-logs"
    Environment = "Portfolio"
  }
}

# Create an IAM role for VPC Flow Logs.
resource "aws_iam_role" "flow_logs_role" {
  name = "secure-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

# Allow VPC Flow Logs to publish to CloudWatch.
resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "secure-vpc-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
      }
    ]
  })
}

# Enable VPC Flow Logs.
resource "aws_flow_log" "secure_vpc" {
  vpc_id               = aws_vpc.secure_vpc.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  iam_role_arn         = aws_iam_role.flow_logs_role.arn

  depends_on = [
    aws_iam_role_policy.flow_logs_policy
  ]

  tags = {
    Name        = "secure-vpc-flow-logs"
    Environment = "Portfolio"
  }
}


# Create a dedicated KMS key for S3 encryption.
resource "aws_kms_key" "s3_storage" {
  description             = "KMS key for secure S3 bucket encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableAccountAdministration"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowS3BucketEncryption"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]

        Resource = "*"

        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.${var.aws_region}.amazonaws.com"
          }

          StringLike = {
            "kms:EncryptionContext:aws:s3:arn" = [
              aws_s3_bucket.secure_storage.arn,
              "${aws_s3_bucket.secure_storage.arn}/*"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name        = "secure-s3-storage-key"
    Environment = "Portfolio"
  }
}

# Enable versioning to protect stored S3 objects.
resource "aws_s3_bucket_versioning" "secure_storage" {
  bucket = aws_s3_bucket.secure_storage.id

  versioning_configuration {
    status = "Enabled"
  }
}