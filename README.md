# AWS Infrastructure Automation

A Terraform-based Infrastructure as Code (IaC) repository for provisioning complete AWS environments including VPC, EC2, RDS, and security groups.

## Overview

This project provides a robust, modular approach to AWS infrastructure deployment using Terraform. It enables consistent, repeatable provisioning of AWS resources across multiple environments (development, staging, production) with proper security configurations and best practices.

## Features

- **Complete Networking Setup**:
  - VPC with public and private subnets across multiple availability zones
  - Internet and NAT gateways for secure outbound connectivity
  - Route tables with proper routing for public/private resources

- **Compute Resources**:
  - Auto Scaling Groups with launch templates
  - IAM instance profiles with least privilege permissions
  - Security groups with proper access controls

- **Database Infrastructure**:
  - Amazon RDS Aurora clusters with proper security
  - Automated backups and maintenance windows
  - Encryption at rest

- **Security Controls**:
  - Layered security groups for different tiers (web, app, database)
  - IAM roles with principle of least privilege
  - VPC network isolation

- **Monitoring and Alerting**:
  - CloudWatch dashboards and alarms
  - SNS notifications for critical events
  - Resource health monitoring

## Project Structure

```
aws-infrastructure/
├── modules/                      # Reusable components
│   ├── networking/               # VPC, subnets, routing
│   ├── compute/                  # EC2, Auto Scaling Groups
│   ├── database/                 # RDS instances
│   ├── security/                 # Security groups, IAM
│   └── monitoring/               # CloudWatch, alarms
├── environments/                 # Environment-specific configurations
│   ├── dev/
│   ├── staging/
│   └── production/
├── scripts/                      # Utility scripts
├── .gitignore
└── versions.tf
```

## Prerequisites

- AWS account with appropriate permissions
- Terraform v1.0.0 or later
- AWS CLI configured locally
- S3 bucket for Terraform state (recommended)

## Getting Started

1. **Clone this repository**:
   ```
   git clone https://github.com/yourusername/aws-infrastructure.git
   cd aws-infrastructure
   ```

2. **Initialize Terraform**:
   ```
   cd environments/dev
   terraform init
   ```

3. **Create a terraform.tfvars file**:
   Create a `terraform.tfvars` file in your environment directory with your specific variables:
   ```
   region = "us-west-2"
   environment = "dev"
   vpc_cidr = "10.0.0.0/16"
   availability_zones = ["us-west-2a", "us-west-2b"]
   private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
   public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
   ```

4. **Plan and apply**:
   ```
   terraform plan
   terraform apply
   ```

## Environment-Specific Deployment

To deploy to different environments:

```bash
# For development
cd environments/dev
terraform apply

# For staging
cd environments/staging
terraform apply

# For production
cd environments/production
terraform apply
```

## Remote State Management

This project uses remote state management for collaboration and state locking:

```hcl
# environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Security Best Practices

- All sensitive variables should be stored in AWS Secrets Manager or similar
- Use IAM roles with minimal required permissions
- Enable encryption at rest for all data storage
- Isolate environments with separate AWS accounts
- Regularly audit security groups and IAM permissions

## Contributing

1. Create a feature branch: `git checkout -b feature/new-feature`
2. Commit your changes: `git commit -am 'Add new feature'`
3. Push to the branch: `git push origin feature/new-feature`
4. Submit a pull request

## Common Commands

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan -out=plan.out

# Apply changes
terraform apply plan.out

# Destroy infrastructure
terraform destroy
```

## Maintenance

- Regularly update Terraform and provider versions
- Monitor cost and usage with AWS Cost Explorer
- Schedule regular security audits
- Keep documentation up-to-date

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or support, please contact me
