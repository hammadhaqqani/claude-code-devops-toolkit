# Claude Code DevOps Toolkit

[![Lint](https://github.com/hammadhaqqani/claude-code-devops-toolkit/actions/workflows/lint.yml/badge.svg)](https://github.com/hammadhaqqani/claude-code-devops-toolkit/actions/workflows/lint.yml)
[![GitHub Pages](https://github.com/hammadhaqqani/claude-code-devops-toolkit/actions/workflows/pages.yml/badge.svg)](https://hammadhaqqani.github.io/claude-code-devops-toolkit/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive collection of CLAUDE.md templates, curated prompts, automation scripts, and project configurations for using Claude Code effectively in DevOps workflows.

## Overview

This toolkit provides everything you need to integrate Claude Code into your DevOps projects, from Infrastructure as Code (IaC) generation to CI/CD pipeline optimization. Whether you're working with Terraform, Kubernetes, Python, or CI/CD pipelines, this repository offers battle-tested templates and prompts to accelerate your development workflow.

## Architecture

```
claude-code-devops-toolkit/
├── templates/          # CLAUDE.md templates for different project types
│   ├── terraform/      # Terraform-specific conventions and patterns
│   ├── kubernetes/     # K8s manifest generation and best practices
│   ├── python/         # Python DevOps tooling standards
│   └── cicd/           # CI/CD pipeline templates
├── prompts/            # Curated prompt library for common DevOps tasks
│   ├── iac-generation.md
│   ├── debugging.md
│   ├── migration.md
│   └── security-review.md
├── scripts/            # Automation scripts for Claude Code workflows
│   ├── setup-claude-project.sh
│   ├── bulk-review.sh
│   └── generate-docs.sh
├── configs/            # Example .claude/ project configurations
│   ├── terraform-project/
│   ├── k8s-project/
│   └── python-project/
└── .github/workflows/  # CI/CD for the toolkit itself
```

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/hammadhaqqani/claude-code-devops-toolkit.git
   cd claude-code-devops-toolkit
   ```

2. **Set up a new project:**
   ```bash
   ./scripts/setup-claude-project.sh terraform my-terraform-project
   ```

3. **Copy the appropriate CLAUDE.md template:**
   ```bash
   cp templates/terraform/CLAUDE.md /path/to/your/project/
   ```

4. **Customize the template** with your project-specific context and conventions.

5. **Start using Claude Code** with your project - it will automatically read the CLAUDE.md file for context.

## Components

### Templates

CLAUDE.md templates provide project-specific context to Claude Code, ensuring consistent code generation and adherence to your team's conventions.

- **terraform/CLAUDE.md**: Terraform-specific guidelines including module structure, naming conventions, state management, and provider configurations
- **kubernetes/CLAUDE.md**: Kubernetes manifest standards, resource naming, namespace organization, and security best practices
- **python/CLAUDE.md**: Python DevOps tooling standards, testing frameworks, dependency management, and deployment patterns
- **cicd/CLAUDE.md**: CI/CD pipeline templates for GitHub Actions, GitLab CI, Jenkins, and other platforms

### Prompts

Curated prompt library for common DevOps tasks:

- **iac-generation.md**: Prompts for generating Infrastructure as Code with Terraform, Pulumi, or CloudFormation
- **debugging.md**: Systematic debugging prompts for infrastructure issues, deployment failures, and configuration errors
- **migration.md**: Step-by-step prompts for migrating between cloud providers, Kubernetes versions, or infrastructure patterns
- **security-review.md**: Security-focused prompts for reviewing IaC, container configurations, and access controls

### Scripts

Automation scripts to streamline Claude Code workflows:

- **setup-claude-project.sh**: Initialize a new project with Claude Code configuration
- **bulk-review.sh**: Review multiple files or directories using Claude Code
- **generate-docs.sh**: Generate documentation from code using Claude Code

### Configs

Example `.claude/settings.json` configurations for different project types:

- **terraform-project/**: Optimized settings for Terraform development
- **k8s-project/**: Settings tailored for Kubernetes manifest management
- **python-project/**: Python-specific Claude Code configuration

## Usage Examples

### Example 1: Generate Terraform Module

```bash
# Use the IaC generation prompt
cat prompts/iac-generation.md | claude-code generate \
  --template templates/terraform/CLAUDE.md \
  --input "Create an S3 bucket module with versioning and encryption"
```

### Example 2: Security Review

```bash
# Review Terraform code for security issues
claude-code review \
  --prompt prompts/security-review.md \
  --files terraform/main.tf terraform/variables.tf
```

### Example 3: Setup New Project

```bash
# Initialize a Kubernetes project with Claude Code
./scripts/setup-claude-project.sh kubernetes my-k8s-app
cd my-k8s-app
cp ../templates/kubernetes/CLAUDE.md .
```

### Example 4: Bulk Code Review

```bash
# Review all Terraform files in a directory
./scripts/bulk-review.sh \
  --directory ./infrastructure \
  --prompt prompts/security-review.md \
  --output review-report.md
```

## Best Practices

1. **Customize Templates**: Always customize CLAUDE.md templates with your project-specific context, team conventions, and organizational standards.

2. **Version Control**: Commit your CLAUDE.md files to version control so all team members benefit from consistent AI assistance.

3. **Iterative Refinement**: Continuously refine your prompts and templates based on what works best for your team.

4. **Security First**: Use security-review prompts regularly, especially before deploying infrastructure changes.

5. **Documentation**: Keep your CLAUDE.md files updated as your project evolves and conventions change.

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository** and create a feature branch
2. **Add or improve** templates, prompts, or scripts
3. **Test your changes** with real projects
4. **Update documentation** as needed
5. **Submit a pull request** with a clear description of changes

### Contribution Areas

- Additional project type templates (Ansible, Chef, Puppet, etc.)
- More specialized prompts for edge cases
- Enhanced automation scripts
- Better example configurations
- Documentation improvements

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs/claude-code)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)

## Support

For issues, questions, or suggestions, please open an issue on GitHub or reach out to the maintainers.

---

**Maintained by**: [hammadhaqqani](https://github.com/hammadhaqqani)

**Last Updated**: February 2026

## See Also

- [Awesome DevOps AI](https://github.com/hammadhaqqani/awesome-devops-ai) - Curated list of 100+ AI tools for DevOps, SRE, and Platform Engineering
- [Free AI & DevOps Tools](https://hammadhaqqani.com/tools) - 41 free browser-based AI and DevOps tools

---

## Support

If you find this useful, consider buying me a coffee!

[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/hammadhaqqani)
