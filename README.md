# Secure AWS Cloud Infrastructure

## Project Overview

A cloud security portfolio project demonstrating the design, configuration, and security assessment of AWS infrastructure using Terraform and Checkov.

This project focuses on Infrastructure as Code (IaC), network security, encryption, identity and access management, and automated security assessments.

## Technologies Used

- Amazon Web Services (AWS)
- Terraform
- Checkov
- Python
- PowerShell
- Visual Studio Code
- Mermaid

## AWS Services

- Amazon VPC
- Amazon S3
- AWS Identity and Access Management (IAM)
- AWS Key Management Service (KMS)
- Amazon CloudWatch
- VPC Flow Logs
- Security Groups

## Security Features

- Network segmentation
- Restrictive security groups
- S3 public access prevention
- KMS encryption
- Automatic encryption key rotation
- S3 object versioning
- HTTPS-only S3 access
- Least-privilege IAM permissions
- Encrypted CloudWatch logs
- 365-day log retention
- Automated infrastructure security scanning

## Security Assessment Results

| Metric | Result |
|---|---|
| Terraform Validation | Successful |
| Total Security Checks | 56 |
| Passed Checks | 52 |
| Failed Checks | 4 |
| Skipped Checks | 0 |
| Checkov Pass Rate | 92.86% |

Remaining security findings, associated risks, and recommended remediation steps are documented in the security assessment report.

## Architecture

[View AWS Architecture Diagram](architecture/architecture.md)

## Security Documentation

- [Checkov Scan Results](security-scans/checkov-results.txt)
- [Security Assessment Report](security-scans/security-findings.md)

## Project Structure

```text
secure-cloud-infrastructure/
├── architecture/
│   └── architecture.md
├── security-scans/
│   ├── checkov-results.txt
│   └── security-findings.md
├── screenshots/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── .gitignore
└── README.md
```

## Skills Demonstrated

- Cloud security architecture
- Infrastructure as Code
- AWS security configuration
- Identity and access management
- Encryption and key management
- Network security
- Security misconfiguration detection
- Risk assessment and remediation planning
- Technical documentation

## Project Limitations

This project was developed and validated locally. No AWS resources have been deployed.

The four remaining security findings are documented for future remediation. Static security scanning does not guarantee production security.

## Author

Juliet DePaz

Aspiring Cloud Security Engineer

- [LinkedIn](https://www.linkedin.com/in/juliet-depaz-3263ab407)
- [GitHub](https://github.com/julesdepaz27-cyber)
