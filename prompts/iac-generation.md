# Infrastructure as Code Generation Prompts

This document contains curated prompts for generating Infrastructure as Code (IaC) using Claude Code.

## Terraform Module Generation

### Basic Prompt Template

```
Generate a Terraform module for [RESOURCE_TYPE] with the following requirements:

**Context:**
- Provider: [AWS/Azure/GCP]
- Environment: [dev/staging/prod]
- Region: [region-name]

**Requirements:**
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

**Constraints:**
- Follow the project's naming conventions (see CLAUDE.md)
- Include proper tags (Environment, Project, ManagedBy)
- Use variables for all configurable values
- Include outputs for important resource attributes
- Add validation blocks for critical variables

**Security:**
- Enable encryption at rest
- Use least-privilege IAM policies
- Enable logging and monitoring

**Output:**
- main.tf with resource definitions
- variables.tf with input variables
- outputs.tf with output values
- versions.tf with provider requirements
- README.md with usage examples
```

### Example: S3 Bucket Module

```
Generate a Terraform module for an AWS S3 bucket with the following requirements:

**Context:**
- Provider: AWS
- Environment: Production
- Region: us-east-1

**Requirements:**
- Enable versioning
- Enable server-side encryption (SSE-S3)
- Block public access
- Enable access logging to another S3 bucket
- Lifecycle policy: transition to Glacier after 30 days, expire after 1 year
- Enable bucket notifications for object creation

**Constraints:**
- Follow naming convention: aws_s3_bucket_{environment}_{purpose}
- Include standard tags: Environment, Project, ManagedBy
- Use variables for bucket name, logging bucket, and lifecycle rules
- Output bucket ID, ARN, and domain name

**Security:**
- Use bucket policies for access control
- Enable MFA delete (optional via variable)
- Enable bucket encryption

**Output:**
Provide complete Terraform module files with proper structure.
```

### Example: VPC Module

```
Create a Terraform module for an AWS VPC with the following specifications:

**Context:**
- Provider: AWS
- Environment: Multi-environment (use variables)
- Region: Configurable

**Requirements:**
- VPC with configurable CIDR block
- Public and private subnets across 3 availability zones
- Internet Gateway for public subnets
- NAT Gateway (one per AZ) for private subnets
- Route tables for public and private subnets
- VPC endpoints for S3 and DynamoDB
- Security groups: web (port 80, 443), app (port 8080), db (port 5432)

**Constraints:**
- Use data sources for availability zones
- Make subnet count configurable
- Include outputs for all subnet IDs, security group IDs
- Use locals for calculated values

**Security:**
- Enable VPC Flow Logs
- Use network ACLs for additional security
- Restrict security group rules to specific CIDR blocks

**Output:**
Complete module structure with all required files.
```

## Kubernetes Manifest Generation

### Basic Prompt Template

```
Generate Kubernetes manifests for [APPLICATION_NAME] with the following requirements:

**Context:**
- Application: [app-name]
- Environment: [dev/staging/prod]
- Namespace: [namespace-name]

**Requirements:**
- Deployment with [N] replicas
- Service (ClusterIP/LoadBalancer)
- ConfigMap for configuration
- [Optional: Ingress, HPA, PDB]

**Constraints:**
- Follow Kubernetes naming conventions
- Include standard labels (app, version, component, environment)
- Set resource requests and limits
- Include liveness and readiness probes
- Use security context (runAsNonRoot, drop capabilities)

**Security:**
- Use non-root user
- Drop all capabilities
- Implement NetworkPolicy
- Use secrets for sensitive data (reference only, don't include values)

**Output:**
- deployment.yaml
- service.yaml
- configmap.yaml
- [Other required manifests]
```

### Example: Web Application Deployment

```
Generate Kubernetes manifests for a web application with these requirements:

**Context:**
- Application: frontend-app
- Environment: Production
- Namespace: production
- Image: frontend-app:1.2.3

**Requirements:**
- Deployment with 3 replicas
- ClusterIP Service exposing port 80
- Ingress with TLS termination
- HorizontalPodAutoscaler (min: 3, max: 10, CPU: 70%)
- PodDisruptionBudget (minAvailable: 2)
- ConfigMap for environment variables

**Constraints:**
- Resource requests: 256Mi memory, 250m CPU
- Resource limits: 512Mi memory, 500m CPU
- Liveness probe: HTTP GET /health, initialDelaySeconds: 30
- Readiness probe: HTTP GET /ready, initialDelaySeconds: 5
- Rolling update strategy: maxSurge: 1, maxUnavailable: 0

**Security:**
- Security context: runAsNonRoot: true, runAsUser: 1000
- Drop all capabilities
- NetworkPolicy: allow ingress from ingress controller, allow egress to backend service

**Output:**
Complete set of Kubernetes manifests following best practices.
```

## Pulumi Program Generation

### Basic Prompt Template

```
Generate a Pulumi program in [LANGUAGE] for [RESOURCE_TYPE] with:

**Context:**
- Language: [Python/TypeScript/Go]
- Cloud Provider: [AWS/Azure/GCP]
- Stack: [dev/staging/prod]

**Requirements:**
- [List of requirements]

**Constraints:**
- Use Pulumi configuration for environment-specific values
- Export important outputs
- Use Pulumi secrets for sensitive values
- Follow language-specific best practices

**Output:**
Complete Pulumi program with Pulumi.yaml configuration.
```

## CloudFormation Template Generation

### Basic Prompt Template

```
Generate an AWS CloudFormation template (YAML) for [RESOURCE_TYPE]:

**Context:**
- Template format: YAML
- Region: [region-name]

**Requirements:**
- [List of requirements]

**Constraints:**
- Use parameters for configurable values
- Use outputs for important resource attributes
- Include metadata and descriptions
- Use conditions for optional resources
- Follow CloudFormation best practices

**Output:**
Complete CloudFormation template with parameters, resources, and outputs.
```

## Best Practices for Prompt Engineering

### 1. Provide Context

Always include:
- Target platform/provider
- Environment (dev/staging/prod)
- Existing infrastructure context
- Team conventions and standards

### 2. Be Specific

Instead of: "Create a database"
Use: "Create an RDS PostgreSQL 15 instance with Multi-AZ, encryption at rest, automated backups, and read replicas"

### 3. Include Constraints

Specify:
- Naming conventions
- Tagging requirements
- Compliance requirements
- Performance requirements

### 4. Request Documentation

Always ask for:
- README with usage examples
- Variable descriptions
- Output descriptions
- Architecture diagrams (if complex)

### 5. Iterate and Refine

- Start with basic requirements
- Review generated code
- Refine prompts based on output
- Build a library of effective prompts

## Example Workflow

1. **Initial Generation:**
   ```
   Generate a basic Terraform module for [resource] with [core requirements]
   ```

2. **Enhancement:**
   ```
   Add to the previous module:
   - [Additional feature 1]
   - [Additional feature 2]
   - Security hardening
   ```

3. **Optimization:**
   ```
   Optimize the module for:
   - Cost reduction
   - Performance
   - Maintainability
   ```

4. **Documentation:**
   ```
   Add comprehensive documentation including:
   - Usage examples
   - Variable descriptions
   - Output descriptions
   - Architecture diagram
   ```

## Common Patterns

### Multi-Environment Setup

```
Generate Terraform configuration that supports multiple environments (dev, staging, prod) using:
- Workspaces or separate state files
- Environment-specific variable files
- Conditional resources based on environment
- Environment-specific tags and naming
```

### Disaster Recovery

```
Generate IaC with disaster recovery capabilities:
- Multi-region deployment
- Automated backup and restore
- Failover mechanisms
- Data replication
```

### Cost Optimization

```
Generate cost-optimized infrastructure:
- Use spot instances where appropriate
- Implement auto-scaling
- Use reserved instances for predictable workloads
- Enable cost monitoring and alerts
```

## Troubleshooting Prompts

### Fix Common Issues

```
Review this Terraform code and fix:
- [Specific error message]
- [Performance issue]
- [Security vulnerability]
- [Best practice violation]
```

### Refactor for Maintainability

```
Refactor this Terraform module to:
- Improve readability
- Reduce duplication
- Better organize resources
- Follow DRY principles
```
