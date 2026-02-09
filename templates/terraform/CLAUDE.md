# Terraform Project Guidelines

This document provides context and conventions for Terraform code generation and modification in this project.

## Project Context

This is a Terraform project for managing cloud infrastructure. All infrastructure should be defined as code, version-controlled, and follow Infrastructure as Code (IaC) best practices.

## Code Style and Conventions

### File Organization

- **Main files**: `main.tf` (resources), `variables.tf` (input variables), `outputs.tf` (output values)
- **Modules**: Place reusable components in `modules/` directory
- **Environments**: Use workspaces or separate directories for different environments (dev, staging, prod)
- **State**: Store state remotely (S3, Terraform Cloud, etc.) - never commit `.tfstate` files

### Naming Conventions

- **Resources**: Use snake_case with descriptive prefixes (e.g., `aws_s3_bucket_app_data`)
- **Variables**: Use snake_case (e.g., `instance_count`, `enable_encryption`)
- **Outputs**: Use snake_case (e.g., `vpc_id`, `database_endpoint`)
- **Modules**: Use descriptive names matching their purpose (e.g., `vpc`, `rds-cluster`, `eks-cluster`)

### Resource Naming Pattern

```
{provider}_{resource_type}_{environment}_{purpose}_{identifier}
```

Example: `aws_s3_bucket_prod_app_logs`

### Tags

Always include these standard tags on all resources:
- `Environment`: dev, staging, prod
- `Project`: Project name
- `ManagedBy`: Terraform
- `CreatedAt`: Timestamp or date

Example:
```hcl
tags = {
  Environment = var.environment
  Project     = var.project_name
  ManagedBy   = "Terraform"
  CreatedAt   = timestamp()
}
```

## Provider Configuration

### AWS Provider

```hcl
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}
```

### Version Constraints

Always specify provider version constraints:
```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## Module Structure

### Standard Module Layout

```
modules/
└── module-name/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    └── README.md
```

### Module Best Practices

- Keep modules focused and single-purpose
- Use variables for all configurable values
- Document all inputs and outputs
- Include examples in README.md
- Version modules using git tags

## Variable Conventions

### Variable Types

- Use specific types: `string`, `number`, `bool`, `list(string)`, `map(string)`
- Provide sensible defaults when appropriate
- Use `nullable = false` for required variables
- Add validation blocks for critical variables

Example:
```hcl
variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}
```

## Output Conventions

- Export only values needed by other modules or external systems
- Use descriptive names
- Include descriptions
- Consider sensitive outputs (use `sensitive = true`)

Example:
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "database_password" {
  description = "Database administrator password"
  value       = aws_db_instance.main.password
  sensitive   = true
}
```

## State Management

### Remote State

Always use remote state backend:
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "project-name/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### State Locking

Enable state locking using DynamoDB or Terraform Cloud to prevent concurrent modifications.

## Security Best Practices

1. **Secrets Management**: Never hardcode secrets. Use:
   - AWS Secrets Manager
   - AWS Systems Manager Parameter Store
   - Environment variables
   - Terraform Cloud variables (marked sensitive)

2. **IAM**: Follow principle of least privilege
   - Use IAM roles instead of access keys when possible
   - Create specific IAM policies for Terraform operations

3. **Encryption**: Enable encryption at rest and in transit:
   - S3 buckets: Enable default encryption
   - RDS: Enable encryption
   - EBS volumes: Enable encryption

4. **Network Security**: 
   - Use private subnets for databases
   - Implement security groups with minimal required access
   - Use VPC endpoints for AWS services

## Testing Requirements

### Pre-commit Checks

- Run `terraform fmt -check` to ensure formatting
- Run `terraform validate` to check syntax
- Run `tflint` for linting
- Run `checkov` or `tfsec` for security scanning

### Testing Workflow

1. **Plan**: Always run `terraform plan` before apply
2. **Review**: Review plan output carefully, especially for destructive changes
3. **Apply**: Use `terraform apply` with `-auto-approve` only in CI/CD pipelines
4. **Verify**: After apply, verify resources are created correctly

## Common Commands

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Destroy resources
terraform destroy

# Show current state
terraform show

# List resources
terraform state list

# Import existing resource
terraform import aws_s3_bucket.example bucket-name

# Workspace management
terraform workspace new dev
terraform workspace select dev
terraform workspace list
```

## Deployment Patterns

### Environment Promotion

1. Develop and test in `dev` workspace
2. Review and apply to `staging` workspace
3. Final review and apply to `prod` workspace

### Change Management

- Always create a feature branch for infrastructure changes
- Require PR review before merging
- Use `terraform plan` output in PR description
- Tag releases with semantic versioning

## Error Handling

- Use `try()` and `can()` functions for optional resources
- Implement proper error messages in validation blocks
- Use `depends_on` for explicit resource dependencies
- Handle provider errors gracefully

## Documentation

- Include README.md in root and each module
- Document all variables and outputs
- Add examples for common use cases
- Keep architecture diagrams updated

## Additional Resources

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
