# CI/CD Pipeline Guidelines

This document provides context and conventions for CI/CD pipeline generation and management in this project.

## Project Context

This project uses CI/CD pipelines for automated testing, building, and deployment. Pipelines should be reliable, secure, and follow infrastructure-as-code principles.

## Pipeline Platforms

### Supported Platforms

- **GitHub Actions**: Primary platform for GitHub repositories
- **GitLab CI**: For GitLab-hosted projects
- **Jenkins**: For self-hosted CI/CD
- **CircleCI**: Alternative cloud CI/CD platform

## Pipeline Structure

### Common Stages

1. **Lint**: Code quality checks (linting, formatting)
2. **Test**: Unit and integration tests
3. **Build**: Create artifacts (Docker images, binaries, packages)
4. **Security Scan**: Vulnerability scanning
5. **Deploy Dev**: Deploy to development environment
6. **Deploy Staging**: Deploy to staging environment (after approval)
7. **Deploy Prod**: Deploy to production (after approval)

### Pipeline Triggers

- **Push to main/master**: Run full pipeline including production deployment
- **Pull Request**: Run lint, test, and security scan
- **Push to feature branch**: Run lint and test
- **Scheduled**: Nightly builds and security scans
- **Manual**: On-demand pipeline execution

## GitHub Actions

### Workflow Structure

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run linters
        run: |
          # Linting commands

  test:
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          # Test commands

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - name: Build artifacts
        run: |
          # Build commands
```

### Best Practices

- Use matrix strategies for multiple versions/runtimes
- Cache dependencies to speed up builds
- Use secrets for sensitive data
- Set appropriate permissions (least privilege)
- Use reusable workflows for common patterns

### Example: Docker Build and Push

```yaml
build-and-push:
  runs-on: ubuntu-latest
  permissions:
    contents: read
    packages: write
  steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
        cache-from: type=gha
        cache-to: type=gha,mode=max
```

## GitLab CI

### Pipeline Configuration

```yaml
# .gitlab-ci.yml
stages:
  - lint
  - test
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"

lint:
  stage: lint
  image: node:18
  script:
    - npm install
    - npm run lint
  only:
    - merge_requests
    - main

test:
  stage: test
  image: python:3.11
  script:
    - pip install -r requirements-dev.txt
    - pytest --cov=src --cov-report=xml
  coverage: '/TOTAL.*\s+(\d+%)$/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main

deploy:
  stage: deploy
  image: alpine:latest
  script:
    - echo "Deploy to production"
  environment:
    name: production
    url: https://app.example.com
  only:
    - main
  when: manual
```

## Jenkins

### Jenkinsfile (Declarative Pipeline)

```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        IMAGE_NAME = 'app-name'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Lint') {
            steps {
                sh 'npm run lint'
            }
        }
        
        stage('Test') {
            steps {
                sh 'pytest --cov=src'
            }
            post {
                always {
                    publishCoverage adapters: [coberturaAdapter('coverage.xml')]
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    def image = docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    image.push()
                    image.push("latest")
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'kubectl set image deployment/app app=${DOCKER_REGISTRY}/${IMAGE_NAME}:${env.BUILD_NUMBER}'
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            emailext (
                subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Build failed. Check console output.",
                to: "${env.CHANGE_AUTHOR_EMAIL}"
            )
        }
    }
}
```

## Security Best Practices

### Secrets Management

- Never commit secrets to version control
- Use platform-specific secret management:
  - GitHub Actions: GitHub Secrets
  - GitLab CI: CI/CD Variables (masked)
  - Jenkins: Credentials plugin
- Rotate secrets regularly
- Use least privilege for service accounts

### Security Scanning

Include security scanning in pipelines:

```yaml
security-scan:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy results to GitHub Security
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
```

## Testing in CI/CD

### Test Execution

- Run tests in parallel when possible
- Use test result reporting (JUnit XML, etc.)
- Fail pipeline on test failures
- Generate coverage reports

### Test Environments

- Use containerized test environments
- Isolate tests from each other
- Clean up test resources after completion
- Use test databases/data stores

## Deployment Strategies

### Blue-Green Deployment

```yaml
deploy-blue-green:
  runs-on: ubuntu-latest
  steps:
    - name: Deploy to blue environment
      run: |
        kubectl apply -f k8s/blue/
    
    - name: Run smoke tests
      run: |
        ./scripts/smoke-tests.sh blue
    
    - name: Switch traffic to blue
      run: |
        kubectl patch service app -p '{"spec":{"selector":{"version":"blue"}}}'
    
    - name: Wait and verify
      run: |
        sleep 60
        ./scripts/health-check.sh
    
    - name: Cleanup green
      if: success()
      run: |
        kubectl delete -f k8s/green/
```

## Best Practices Summary

1. **Fail Fast**: Run fast checks (lint, format) before slow tests
2. **Parallel Execution**: Run independent jobs in parallel
3. **Caching**: Cache dependencies and build artifacts
4. **Idempotency**: Ensure deployments are idempotent
5. **Rollback**: Always have a rollback strategy
6. **Documentation**: Document pipeline changes and decisions
7. **Versioning**: Tag releases and deployments
8. **Testing**: Test pipeline changes in feature branches first

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [CI/CD Best Practices](https://www.atlassian.com/continuous-delivery/principles/continuous-integration-vs-delivery-vs-deployment)
