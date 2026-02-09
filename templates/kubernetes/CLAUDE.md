# Kubernetes Project Guidelines

This document provides context and conventions for Kubernetes manifest generation and management in this project.

## Project Context

This project manages Kubernetes resources using declarative manifests. All resources should be version-controlled, follow Kubernetes best practices, and be deployable across multiple environments.

## Code Style and Conventions

### File Organization

- **Manifests**: Organize by resource type or application component
- **Environments**: Separate directories for `dev/`, `staging/`, `prod/`
- **Base/Overlays**: Use Kustomize base/overlay pattern for environment-specific configs
- **Helm Charts**: Place reusable components in `charts/` directory

### Directory Structure

```
k8s/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── charts/
    └── app-name/
```

### Naming Conventions

- **Resources**: Use lowercase with hyphens (e.g., `app-frontend`, `db-backend`)
- **Labels**: Use consistent label keys: `app`, `version`, `component`, `environment`
- **Namespaces**: Use lowercase (e.g., `production`, `staging`, `development`)
- **ConfigMaps/Secrets**: Use descriptive names matching their purpose

### Label Standards

Always include these standard labels:
```yaml
labels:
  app: application-name
  version: "1.0.0"
  component: frontend|backend|database
  environment: dev|staging|prod
  managed-by: kubernetes
```

## Resource Patterns

### Deployments

- Always specify resource requests and limits
- Use `replicas: 2` minimum for production
- Set appropriate `revisionHistoryLimit`
- Use `strategy.type: RollingUpdate` with proper `maxSurge` and `maxUnavailable`

Example:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-frontend
  labels:
    app: app-frontend
    component: frontend
spec:
  replicas: 3
  revisionHistoryLimit: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: app-frontend
  template:
    metadata:
      labels:
        app: app-frontend
    spec:
      containers:
      - name: app
        image: app:1.0.0
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### Services

- Use ClusterIP for internal services
- Use LoadBalancer or NodePort only when necessary
- Always define `selector` matching pod labels
- Use meaningful port names

### ConfigMaps and Secrets

- Never commit secrets to version control
- Use external secret management (Sealed Secrets, External Secrets Operator, etc.)
- Store non-sensitive config in ConfigMaps
- Use `immutable: true` for ConfigMaps that don't change

### Namespaces

- Create separate namespaces per environment
- Use ResourceQuotas and LimitRanges
- Apply NetworkPolicies for network isolation

## Security Best Practices

### Pod Security

1. **Security Context**: Always set security context
   ```yaml
   securityContext:
     runAsNonRoot: true
     runAsUser: 1000
     fsGroup: 2000
     allowPrivilegeEscalation: false
     capabilities:
       drop:
       - ALL
   ```

2. **Image Security**:
   - Use specific image tags (avoid `latest`)
   - Scan images for vulnerabilities
   - Use images from trusted registries
   - Prefer distroless or minimal base images

3. **Network Policies**: Implement network policies for pod-to-pod communication
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: NetworkPolicy
   metadata:
     name: app-network-policy
   spec:
     podSelector:
       matchLabels:
         app: app-frontend
     policyTypes:
     - Ingress
     - Egress
     ingress:
     - from:
       - podSelector:
           matchLabels:
             app: app-backend
       ports:
       - protocol: TCP
         port: 8080
   ```

4. **RBAC**: Follow principle of least privilege
   - Create specific ServiceAccounts for each application
   - Use Role/RoleBinding for namespace-scoped permissions
   - Use ClusterRole/ClusterRoleBinding sparingly

### Secrets Management

- Use Kubernetes Secrets for sensitive data (base64 encoded)
- Prefer External Secrets Operator or Sealed Secrets
- Rotate secrets regularly
- Never log or expose secrets

## Resource Management

### Resource Requests and Limits

Always specify both requests and limits:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### Health Checks

Implement liveness and readiness probes:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 3
```

## Deployment Strategies

### Rolling Updates

Default strategy for zero-downtime deployments:
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

### Blue-Green Deployments

Use separate Deployments and switch Service selectors.

### Canary Deployments

Use Argo Rollouts or Flagger for canary deployments.

## Environment Management

### Kustomize Overlays

Use Kustomize for environment-specific configurations:
```yaml
# base/kustomization.yaml
resources:
- deployment.yaml
- service.yaml

# overlays/prod/kustomization.yaml
resources:
- ../../base
patches:
- path: replica-patch.yaml
```

### Helm Values

When using Helm, maintain separate values files:
```
charts/app/
├── Chart.yaml
├── values.yaml
├── values-dev.yaml
├── values-staging.yaml
└── values-prod.yaml
```

## Common Commands

```bash
# Apply manifests
kubectl apply -f manifests/

# Apply with Kustomize
kubectl apply -k overlays/prod/

# Get resources
kubectl get pods -n namespace-name
kubectl get deployments,services -n namespace-name

# Describe resource
kubectl describe pod pod-name -n namespace-name

# View logs
kubectl logs pod-name -n namespace-name
kubectl logs -f deployment/app-name -n namespace-name

# Execute command in pod
kubectl exec -it pod-name -n namespace-name -- /bin/sh

# Port forward
kubectl port-forward service/app-service 8080:80 -n namespace-name

# Delete resources
kubectl delete -f manifests/
kubectl delete pod pod-name -n namespace-name

# Scale deployment
kubectl scale deployment app-name --replicas=5 -n namespace-name

# Rollout status
kubectl rollout status deployment/app-name -n namespace-name

# Rollback
kubectl rollout undo deployment/app-name -n namespace-name
```

## Testing Requirements

### Pre-deployment Checks

- Validate YAML syntax: `kubectl apply --dry-run=client -f manifest.yaml`
- Use `kubeval` or `kube-score` for validation
- Test in dev environment first
- Review resource requests/limits

### Validation Tools

- **kubeval**: Validate Kubernetes YAML files
- **kube-score**: Static code analysis for Kubernetes
- **polaris**: Kubernetes best practices checker
- **kubectl diff**: Preview changes before applying

## Monitoring and Observability

### Labels for Monitoring

Ensure resources have labels for Prometheus/Grafana:
```yaml
labels:
  app: app-name
  component: frontend
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
```

### Logging

- Use structured logging (JSON format)
- Include correlation IDs
- Set appropriate log levels
- Use sidecar containers for log aggregation if needed

## Documentation

- Document all custom resources and their purposes
- Include architecture diagrams
- Document environment-specific configurations
- Keep README.md updated with deployment instructions

## Additional Resources

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [Kustomize Documentation](https://kustomize.io/)
- [Helm Documentation](https://helm.sh/docs/)
