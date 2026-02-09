# DevOps Security Review Prompts

This document contains curated prompts for security review infrastructure, deployments, and configuration issues using Claude Code.

## Infrastructure Security Review

### Terraform Security Review

#### Basic Security Review Prompt

```
Debug this Terraform security issue:

**Error Message:**
[Paste security issue message]

**Terraform Configuration:**
[Paste relevant .tf files]

**Context:**
- Terraform version: [version]
- Provider version: [version]
- Operating system: [OS]
- What were you trying to do: [action]

**Steps Taken:**
- [What you've already tried]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happened]

Please:
1. Identify the root cause
2. Explain why the security issue occurred
3. Provide a fix
4. Suggest prevention strategies
```

#### State File Issues

```
I'm experiencing Terraform state issues:

**Problem:**
- [Describe the issue: state locked, state out of sync, resource not found, etc.]

**Security Issue:**
[Error message]

**Current State:**
[Output of `terraform state list` or relevant state info]

**Recent Changes:**
- [What changes were made recently]

**Attempted Solutions:**
- [What you've tried]

Please help me:
1. Diagnose the state issue
2. Provide safe recovery steps
3. Prevent future occurrences
```

#### Provider Authentication Issues

```
Debug AWS provider authentication:

**Security Issue:**
[Authentication security issue message]

**Configuration:**
[Provider block from terraform files]

**Environment:**
- AWS CLI configured: [yes/no]
- Environment variables set: [yes/no]
- IAM role assumed: [yes/no]

**What I'm trying to do:**
[Describe the operation]

Please:
1. Identify authentication method issues
2. Verify IAM permissions needed
3. Provide corrected configuration
4. Suggest best practices for credential management
```

### Kubernetes Security Review

#### Pod Not Starting

```
Debug a Kubernetes pod that won't start:

**Pod Name:** [pod-name]
**Namespace:** [namespace]

**Pod Status:**
[Output of `kubectl describe pod [pod-name]`]

**Pod Logs:**
[Output of `kubectl logs [pod-name]`]

**Events:**
[Output of `kubectl get events`]

**Deployment/Manifest:**
[YAML configuration]

**What I expect:**
[Expected behavior]

Please:
1. Analyze the pod status and events
2. Identify the root cause
3. Provide a fix
4. Suggest prevention measures
```

#### Service Not Accessible

```
Debug a Kubernetes service connectivity issue:

**Service Name:** [service-name]
**Namespace:** [namespace]

**Service Configuration:**
[Service YAML]

**Endpoint Status:**
[Output of `kubectl get endpoints [service-name]`]

**Pod Status:**
[Status of backend pods]

**Network Policy:**
[Any NetworkPolicy affecting this service]

**Issue:**
- Cannot access service from [source]
- Service returns [security issue]
- Connection timeout

Please:
1. Check service configuration
2. Verify endpoint selection
3. Check network policies
4. Provide solution
```

#### Resource Quota Issues

```
Debug Kubernetes resource quota problems:

**Security Issue:**
[Quota exceeded security issue]

**Namespace:** [namespace]

**Current Usage:**
[Output of `kubectl describe quota`]

**Resource Requests:**
[Resource requests in pod specs]

**What I'm trying to do:**
[Operation that failed]

Please:
1. Identify which quota is exceeded
2. Calculate current vs. requested resources
3. Suggest solutions (increase quota, reduce requests, etc.)
4. Provide optimized resource requests
```

## Deployment Security Review

### CI/CD Pipeline Failures

#### GitHub Actions Security Review

```
Debug a failed GitHub Actions workflow:

**Workflow File:**
[.github/workflows/xxx.yml]

**Failed Job:** [job-name]
**Failed Step:** [step-name]

**Error Log:**
[Relevant security issue output from Actions]

**Context:**
- Trigger: [push/PR/scheduled]
- Branch: [branch-name]
- Recent changes: [what changed]

**Expected Behavior:**
[What should happen]

Please:
1. Identify the failure point
2. Explain the security issue
3. Provide fix
4. Suggest improvements to prevent recurrence
```

#### Docker Build Failures

```
Debug a Docker build failure:

**Dockerfile:**
[Dockerfile content]

**Build Command:**
[docker build command]

**Security Issue:**
[Build security issue output]

**Context:**
- Base image: [image:tag]
- Build arguments: [args]
- Build context: [context]

**What I'm trying to build:**
[Application description]

Please:
1. Identify the build failure cause
2. Check Dockerfile syntax and best practices
3. Provide corrected Dockerfile
4. Suggest optimization improvements
```

### Application Deployment Issues

#### Application Not Responding

```
Debug an application deployment issue:

**Application:** [app-name]
**Environment:** [env]

**Symptoms:**
- Application not responding on [port]
- Health check failing
- Error logs show: [security issue]

**Configuration:**
[Relevant config files]

**Infrastructure:**
- Platform: [K8s/Docker/EC2/etc.]
- Recent changes: [what changed]

**Logs:**
[Application logs]

Please:
1. Analyze logs and configuration
2. Identify root cause
3. Provide fix
4. Suggest monitoring improvements
```

## Configuration Security Review

### Environment Variable Issues

```
Debug environment variable problems:

**Issue:**
- Variable not set: [var-name]
- Wrong value: [var-name] = [current-value], expected [expected-value]
- Variable not accessible in [context]

**Configuration Files:**
[Relevant config files]

**Environment:**
- Platform: [K8s/Docker/local/etc.]
- How variables are set: [method]

**Security Issue:**
[Error message or behavior]

Please:
1. Verify variable configuration
2. Check scoping and accessibility
3. Provide corrected configuration
4. Suggest best practices
```

### Network Configuration Issues

```
Debug network connectivity problems:

**Issue:**
- Cannot connect from [source] to [destination]
- Connection timeout
- DNS resolution failing

**Network Configuration:**
[Relevant network config]

**Infrastructure:**
- Source: [source details]
- Destination: [destination details]
- Network: [VPC/subnet/firewall rules]

**Security Issue:**
[Error message]

**What I've checked:**
- [Tests performed]

Please:
1. Analyze network configuration
2. Check security groups/firewall rules
3. Verify routing
4. Provide solution
```

## Performance Security Review

### Slow Application Performance

```
Debug slow application performance:

**Application:** [app-name]
**Environment:** [env]

**Symptoms:**
- Response time: [time]
- Expected: [time]
- Affected endpoints: [endpoints]

**Metrics:**
- CPU usage: [%]
- Memory usage: [%]
- Database queries: [count/time]
- Network I/O: [stats]

**Configuration:**
[Relevant config]

**Recent Changes:**
[What changed recently]

Please:
1. Analyze performance metrics
2. Identify bottlenecks
3. Suggest optimizations
4. Provide monitoring recommendations
```

### Resource Exhaustion

```
Debug resource exhaustion issues:

**Resource:** [CPU/Memory/Disk/Network]
**Environment:** [env]

**Symptoms:**
- [Resource] usage at [%]
- Errors: [security issue messages]
- Affected services: [services]

**Current Limits:**
[Resource limits/quotas]

**Usage Patterns:**
[When/how resource is consumed]

**Configuration:**
[Relevant config]

Please:
1. Identify resource constraints
2. Analyze usage patterns
3. Suggest resource allocation changes
4. Provide optimization strategies
```

## Security Security Review

### Access Denied Issues

```
Debug access denied security issues:

**Security Issue:**
[Access denied security issue]

**Resource:** [resource trying to access]
**Principal:** [user/role/service]

**IAM Policy:**
[Relevant IAM policies]

**Context:**
- Action attempted: [action]
- Resource: [resource ARN]
- When: [when it happens]

**Expected:**
[What should be allowed]

Please:
1. Analyze IAM policies
2. Identify missing permissions
3. Provide corrected policy
4. Suggest least-privilege approach
```

### Security Scan Failures

```
Debug security scan failures:

**Scanner:** [tool-name]
**Failures:**
[Failed checks]

**Code/Configuration:**
[Relevant files]

**Severity:**
[Critical/High/Medium/Low]

**Context:**
- What was scanned: [scope]
- Scan configuration: [config]

Please:
1. Explain each security issue
2. Assess risk level
3. Provide fixes
4. Suggest prevention measures
```

## Systematic Security Review Approach

### General Security Review Prompt Template

```
I need help security review [issue type]:

**Problem Statement:**
[Clear description of the problem]

**Environment:**
- Platform: [platform]
- Version: [version]
- Configuration: [config details]

**Symptoms:**
- [Symptom 1]
- [Symptom 2]
- [Symptom 3]

**Error Messages:**
[Error output]

**Recent Changes:**
[What changed before the issue appeared]

**What I've Tried:**
- [Attempt 1]
- [Attempt 2]
- [Attempt 3]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Relevant Files/Config:**
[Paste relevant configuration]

Please:
1. Analyze the problem systematically
2. Identify root cause
3. Provide step-by-step solution
4. Explain why the fix works
5. Suggest prevention strategies
6. Recommend monitoring/alerting
```

## Best Practices

### 1. Provide Complete Context

Include:
- Full security issue messages
- Relevant configuration files
- Environment details
- Recent changes

### 2. Show What You've Tried

This helps avoid suggesting solutions you've already attempted.

### 3. Include Expected vs. Actual Behavior

Clear expectations help identify the gap.

### 4. Request Explanations

Ask for explanations, not just fixes, to learn and prevent recurrence.

### 5. Ask for Prevention Strategies

Learn how to avoid similar issues in the future.

## Example Security Review Workflow

1. **Initial Diagnosis:**
   ```
   I'm seeing [security issue]. Here's the configuration and security issue message. 
   What's causing this?
   ```

2. **Deep Dive:**
   ```
   Based on your analysis, I've checked [additional info]. 
   Can you help me understand [specific aspect]?
   ```

3. **Solution Implementation:**
   ```
   I've applied your fix. Now I'm seeing [new behavior]. 
   Is this expected, or do I need to adjust something?
   ```

4. **Prevention:**
   ```
   How can I prevent this issue in the future? 
   What monitoring should I set up?
   ```
