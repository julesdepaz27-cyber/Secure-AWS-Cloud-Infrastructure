# AWS Secure Cloud Infrastructure Architecture

## Architecture Diagram

```mermaid
flowchart TB
    subgraph AWS["AWS Cloud - us-west-2"]
        subgraph VPC["Secure VPC - 10.0.0.0/16"]
            Private["Private Subnet - 10.0.1.0/24"]
            Public["Reserved Subnet - 10.0.2.0/24"]
            SG["Restrictive Security Group"]
            DefaultSG["Restricted Default Security Group"]
        end

        S3["Secure S3 Bucket"]
        KMS1["S3 KMS Encryption Key"]
        KMS2["CloudWatch KMS Encryption Key"]
        Flow["VPC Flow Logs"]
        IAM["IAM Role and Policy"]
        CW["CloudWatch Logs - 365 Day Retention"]

        VPC --> Flow
        Flow --> CW
        IAM --> Flow
        KMS1 --> S3
        KMS2 --> CW
    end

    Terraform["Terraform Infrastructure as Code"] -.-> AWS
    Checkov["Checkov Security Scanner"] --> Terraform
```

## Architecture Components

| Component | Purpose |
|---|---|
| Amazon VPC | Network isolation |
| Subnets | Network segmentation |
| Security Groups | Restrictive network access |
| Amazon S3 | Secure object storage |
| AWS KMS | Encryption and key management |
| AWS IAM | Access and permission management |
| VPC Flow Logs | Network traffic monitoring |
| Amazon CloudWatch | Centralized log storage |
| Terraform | Infrastructure as Code |
| Checkov | Static security analysis |

## Deployment Status

This architecture represents a locally validated Terraform configuration. No AWS resources have been deployed.

The reserved subnet does not currently have internet routing. The custom security group is not attached to a workload.
