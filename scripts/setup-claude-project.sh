#!/bin/bash

# setup-claude-project.sh
# Initialize a new project with Claude Code configuration
#
# Usage: ./setup-claude-project.sh <project-type> <project-name> [options]
#
# Project types: terraform, kubernetes, python, cicd
#
# Options:
#   -d, --directory DIR    Target directory (default: current directory)
#   -t, --template TEMPLATE Use specific template file
#   -h, --help            Show this help message

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory (where this script is located)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default values
PROJECT_TYPE=""
PROJECT_NAME=""
TARGET_DIR="."
TEMPLATE_FILE=""

# Function to display help
show_help() {
    cat << EOF
Claude Code Project Setup Script

Usage: $0 <project-type> <project-name> [options]

Arguments:
  project-type          Type of project (terraform, kubernetes, python, cicd)
  project-name          Name of the project

Options:
  -d, --directory DIR   Target directory for project (default: current directory)
  -t, --template FILE   Use specific template file (overrides project-type)
  -h, --help           Show this help message

Project Types:
  terraform             Terraform infrastructure project
  kubernetes            Kubernetes manifest project
  python                Python DevOps tooling project
  cicd                  CI/CD pipeline project

Examples:
  $0 terraform my-infra
  $0 kubernetes my-app -d ./projects
  $0 python my-tool --template custom-template.md

EOF
}

# Function to log messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                TARGET_DIR="$2"
                shift 2
                ;;
            -t|--template)
                TEMPLATE_FILE="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                if [[ -z "$PROJECT_TYPE" ]]; then
                    PROJECT_TYPE="$1"
                elif [[ -z "$PROJECT_NAME" ]]; then
                    PROJECT_NAME="$1"
                else
                    log_error "Too many arguments"
                    show_help
                    exit 1
                fi
                shift
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$PROJECT_TYPE" ]] && [[ -z "$TEMPLATE_FILE" ]]; then
        log_error "Project type or template file is required"
        show_help
        exit 1
    fi

    if [[ -z "$PROJECT_NAME" ]]; then
        log_error "Project name is required"
        show_help
        exit 1
    fi
}

# Function to determine template path
get_template_path() {
    if [[ -n "$TEMPLATE_FILE" ]]; then
        if [[ -f "$TEMPLATE_FILE" ]]; then
            echo "$TEMPLATE_FILE"
        elif [[ -f "$REPO_ROOT/$TEMPLATE_FILE" ]]; then
            echo "$REPO_ROOT/$TEMPLATE_FILE"
        else
            log_error "Template file not found: $TEMPLATE_FILE"
            exit 1
        fi
    else
        case "$PROJECT_TYPE" in
            terraform)
                echo "$REPO_ROOT/templates/terraform/CLAUDE.md"
                ;;
            kubernetes|k8s)
                echo "$REPO_ROOT/templates/kubernetes/CLAUDE.md"
                ;;
            python)
                echo "$REPO_ROOT/templates/python/CLAUDE.md"
                ;;
            cicd|ci-cd)
                echo "$REPO_ROOT/templates/cicd/CLAUDE.md"
                ;;
            *)
                log_error "Unknown project type: $PROJECT_TYPE"
                log_info "Available types: terraform, kubernetes, python, cicd"
                exit 1
                ;;
        esac
    fi
}

# Function to get config directory
get_config_dir() {
    case "$PROJECT_TYPE" in
        terraform)
            echo "$REPO_ROOT/configs/terraform-project"
            ;;
        kubernetes|k8s)
            echo "$REPO_ROOT/configs/k8s-project"
            ;;
        python)
            echo "$REPO_ROOT/configs/python-project"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to setup project
setup_project() {
    local project_dir="$TARGET_DIR/$PROJECT_NAME"
    local template_path=$(get_template_path)
    local config_dir=$(get_config_dir)

    log_info "Setting up Claude Code project: $PROJECT_NAME"
    log_info "Project type: $PROJECT_TYPE"
    log_info "Target directory: $project_dir"

    # Create project directory
    if [[ -d "$project_dir" ]]; then
        log_warn "Directory already exists: $project_dir"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Aborted"
            exit 0
        fi
    else
        mkdir -p "$project_dir"
        log_info "Created project directory: $project_dir"
    fi

    # Copy CLAUDE.md template
    if [[ -f "$template_path" ]]; then
        cp "$template_path" "$project_dir/CLAUDE.md"
        log_info "Copied CLAUDE.md template"
    else
        log_error "Template not found: $template_path"
        exit 1
    fi

    # Copy .claude configuration if available
    if [[ -n "$config_dir" ]] && [[ -d "$config_dir" ]]; then
        if [[ -d "$config_dir/.claude" ]]; then
            cp -r "$config_dir/.claude" "$project_dir/"
            log_info "Copied .claude configuration"
        fi
    fi

    # Create basic project structure based on type
    case "$PROJECT_TYPE" in
        terraform)
            mkdir -p "$project_dir/modules"
            touch "$project_dir/main.tf"
            touch "$project_dir/variables.tf"
            touch "$project_dir/outputs.tf"
            touch "$project_dir/versions.tf"
            log_info "Created Terraform file structure"
            ;;
        kubernetes|k8s)
            mkdir -p "$project_dir/base"
            mkdir -p "$project_dir/overlays/dev"
            mkdir -p "$project_dir/overlays/staging"
            mkdir -p "$project_dir/overlays/prod"
            touch "$project_dir/base/kustomization.yaml"
            log_info "Created Kubernetes directory structure"
            ;;
        python)
            mkdir -p "$project_dir/src/$PROJECT_NAME"
            mkdir -p "$project_dir/tests"
            touch "$project_dir/src/$PROJECT_NAME/__init__.py"
            touch "$project_dir/requirements.txt"
            touch "$project_dir/requirements-dev.txt"
            log_info "Created Python project structure"
            ;;
    esac

    # Create .gitignore if it doesn't exist
    if [[ ! -f "$project_dir/.gitignore" ]]; then
        cat > "$project_dir/.gitignore" << 'EOF'
# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
.idea/
*.swp
*.swo

# Environment
.env
.venv
venv/

# Temporary files
*.tmp
*.log
EOF
        log_info "Created .gitignore"
    fi

    # Initialize git repository if git is available
    if command_exists git && [[ ! -d "$project_dir/.git" ]]; then
        cd "$project_dir"
        git init
        log_info "Initialized git repository"
        cd - > /dev/null
    fi

    log_info "Project setup complete!"
    log_info "Next steps:"
    log_info "  1. Review and customize CLAUDE.md"
    log_info "  2. Update project-specific configuration"
    log_info "  3. Start using Claude Code with your project"
    echo
    log_info "Project location: $project_dir"
}

# Main execution
main() {
    parse_args "$@"
    setup_project
}

# Run main function
main "$@"
