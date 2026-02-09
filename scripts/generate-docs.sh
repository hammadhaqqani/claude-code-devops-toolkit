#!/bin/bash

# generate-docs.sh
# Generate documentation from code using Claude Code
#
# Usage: ./generate-docs.sh [options]
#
# Options:
#   -d, --directory DIR    Source directory (default: current directory)
#   -o, --output DIR       Output directory for docs (default: ./docs)
#   -t, --type TYPE        Documentation type: api, architecture, readme (default: all)
#   -f, --format FORMAT    Output format: markdown, html (default: markdown)
#   -p, --project NAME     Project name for documentation
#   -h, --help            Show this help message

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default values
SOURCE_DIR="."
OUTPUT_DIR="./docs"
DOC_TYPE="all"
OUTPUT_FORMAT="markdown"
PROJECT_NAME=""

# Function to display help
show_help() {
    cat << EOF
Documentation Generation Script for Claude Code

Usage: $0 [options]

Options:
  -d, --directory DIR    Source directory to document (default: current directory)
  -o, --output DIR       Output directory for generated docs (default: ./docs)
  -t, --type TYPE        Documentation type: api, architecture, readme, all (default: all)
  -f, --format FORMAT    Output format: markdown, html (default: markdown)
  -p, --project NAME     Project name for documentation
  -h, --help            Show this help message

Documentation Types:
  api            Generate API documentation from code
  architecture   Generate architecture documentation from infrastructure
  readme         Generate or update README.md

Examples:
  $0 -d ./src -o ./docs -t api -p "My Project"
  $0 -d . -t readme -p "Infrastructure Project"
  $0 -d ./terraform -t architecture

Note: This script generates documentation templates. Actual documentation
      generation would require Claude Code integration.

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

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                SOURCE_DIR="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_DIR="$2"
                shift 2
                ;;
            -t|--type)
                DOC_TYPE="$2"
                shift 2
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -p|--project)
                PROJECT_NAME="$2"
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
                log_error "Unexpected argument: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Function to detect project type
detect_project_type() {
    if [[ -f "$SOURCE_DIR/main.tf" ]] || [[ -f "$SOURCE_DIR/*.tf" ]]; then
        echo "terraform"
    elif [[ -f "$SOURCE_DIR/requirements.txt" ]] || [[ -f "$SOURCE_DIR/setup.py" ]]; then
        echo "python"
    elif [[ -f "$SOURCE_DIR/package.json" ]]; then
        echo "nodejs"
    elif find "$SOURCE_DIR" -name "*.yaml" -o -name "*.yml" | grep -q "kind:\|apiVersion:" > /dev/null 2>&1; then
        echo "kubernetes"
    else
        echo "generic"
    fi
}

# Function to generate API documentation
generate_api_docs() {
    local output_file="$OUTPUT_DIR/API.md"
    local project_type=$(detect_project_type)
    
    log_info "Generating API documentation..."

    cat > "$output_file" << EOF
# API Documentation

${PROJECT_NAME:+**Project:** $PROJECT_NAME
}
**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**Project Type:** $project_type
**Source Directory:** $SOURCE_DIR

---

## Overview

This document describes the API and interfaces provided by this project.

## Modules/Components

EOF

    # Detect and list modules/components
    case "$project_type" in
        python)
            find "$SOURCE_DIR" -type f -name "*.py" -not -path "*/__pycache__/*" | while read -r file; do
                local module=$(basename "$file" .py)
                echo "### $module" >> "$output_file"
                echo "" >> "$output_file"
                echo "**File:** \`$file\`" >> "$output_file"
                echo "" >> "$output_file"
                echo "**Description:**" >> "$output_file"
                echo "_Extract from docstrings using Claude Code_" >> "$output_file"
                echo "" >> "$output_file"
                echo "**Functions/Classes:**" >> "$output_file"
                echo "- _List functions and classes using Claude Code_" >> "$output_file"
                echo "" >> "$output_file"
            done
            ;;
        terraform)
            find "$SOURCE_DIR" -type f -name "*.tf" | while read -r file; do
                local module=$(basename "$(dirname "$file")")
                echo "### $module" >> "$output_file"
                echo "" >> "$output_file"
                echo "**File:** \`$file\`" >> "$output_file"
                echo "" >> "$output_file"
                echo "**Resources:**" >> "$output_file"
                grep -E "^resource |^module |^data " "$file" 2>/dev/null | sed 's/^/- /' >> "$output_file" || echo "- _No resources found_" >> "$output_file"
                echo "" >> "$output_file"
            done
            ;;
        *)
            echo "### Components" >> "$output_file"
            echo "" >> "$output_file"
            echo "_Use Claude Code to analyze code structure and generate API documentation_" >> "$output_file"
            ;;
    esac

    cat >> "$output_file" << EOF

---

## Usage Examples

_Add usage examples for each module/component_

## Reference

_Detailed API reference generated using Claude Code_

EOF

    log_info "API documentation generated: $output_file"
}

# Function to generate architecture documentation
generate_architecture_docs() {
    local output_file="$OUTPUT_DIR/ARCHITECTURE.md"
    local project_type=$(detect_project_type)
    
    log_info "Generating architecture documentation..."

    cat > "$output_file" << EOF
# Architecture Documentation

${PROJECT_NAME:+**Project:** $PROJECT_NAME
}
**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**Project Type:** $project_type
**Source Directory:** $SOURCE_DIR

---

## Overview

This document describes the architecture and design of this project.

## System Architecture

\`\`\`
_Generate architecture diagram using Claude Code based on infrastructure code_
\`\`\`

## Components

EOF

    case "$project_type" in
        terraform)
            cat >> "$output_file" << EOF

### Infrastructure Components

_Use Claude Code to analyze Terraform files and document:_

- VPC and networking setup
- Compute resources
- Storage resources
- Security configurations
- Monitoring and logging

### Resource Dependencies

\`\`\`
_Generate dependency graph using Claude Code_
\`\`\`

EOF
            ;;
        kubernetes)
            cat >> "$output_file" << EOF

### Kubernetes Resources

_Use Claude Code to analyze manifests and document:_

- Namespaces and organization
- Deployments and workloads
- Services and networking
- ConfigMaps and Secrets
- Persistent volumes
- Network policies

### Deployment Architecture

\`\`\`
_Generate deployment diagram using Claude Code_
\`\`\`

EOF
            ;;
        *)
            cat >> "$output_file" << EOF

### System Components

_Use Claude Code to analyze codebase and document system architecture_

EOF
            ;;
    esac

    cat >> "$output_file" << EOF

## Data Flow

_Describe data flow through the system_

## Security Architecture

_Document security measures and controls_

## Scalability and Performance

_Discuss scalability considerations and performance characteristics_

## Deployment

_Describe deployment process and architecture_

---

## Diagrams

_Generate diagrams using Claude Code:_
- System architecture diagram
- Component interaction diagram
- Data flow diagram
- Deployment diagram

EOF

    log_info "Architecture documentation generated: $output_file"
}

# Function to generate README
generate_readme() {
    local output_file="$OUTPUT_DIR/README.md"
    local project_type=$(detect_project_type)
    
    log_info "Generating README documentation..."

    cat > "$output_file" << EOF
# ${PROJECT_NAME:-Project Name}

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')
**Project Type:** $project_type

## Description

_Use Claude Code to generate project description based on code analysis_

## Features

_List key features extracted using Claude Code_

## Requirements

_List requirements and dependencies_

## Installation

\`\`\`bash
# Installation instructions generated using Claude Code
\`\`\`

## Usage

\`\`\`bash
# Usage examples generated using Claude Code
\`\`\`

## Configuration

_Configuration options and examples_

## Development

_Development setup and guidelines_

## Testing

_Testing instructions_

## Deployment

_Deployment instructions_

## Architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed architecture documentation.

## API Reference

See [API.md](./API.md) for API documentation.

## Contributing

_Contributing guidelines_

## License

_License information_

## Authors

_Author information_

---

**Note:** This README was generated using Claude Code. Review and customize as needed.

EOF

    log_info "README generated: $output_file"
}

# Function to convert markdown to HTML (basic)
convert_to_html() {
    if command -v pandoc > /dev/null 2>&1; then
        log_info "Converting markdown to HTML..."
        find "$OUTPUT_DIR" -name "*.md" | while read -r md_file; do
            local html_file="${md_file%.md}.html"
            pandoc "$md_file" -o "$html_file" --standalone --css="$REPO_ROOT/docs/style.css" 2>/dev/null || true
        done
    else
        log_warn "pandoc not found. HTML conversion skipped."
        log_info "Install pandoc for HTML output: https://pandoc.org/installing.html"
    fi
}

# Main execution
main() {
    parse_args "$@"

    # Validate source directory
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory not found: $SOURCE_DIR"
        exit 1
    fi

    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    log_info "Output directory: $OUTPUT_DIR"

    # Detect project name if not provided
    if [[ -z "$PROJECT_NAME" ]]; then
        PROJECT_NAME=$(basename "$(cd "$SOURCE_DIR" && pwd)")
    fi

    log_info "Project: $PROJECT_NAME"
    log_info "Project type: $(detect_project_type)"

    # Generate documentation based on type
    case "$DOC_TYPE" in
        api)
            generate_api_docs
            ;;
        architecture)
            generate_architecture_docs
            ;;
        readme)
            generate_readme
            ;;
        all)
            generate_api_docs
            generate_architecture_docs
            generate_readme
            ;;
        *)
            log_error "Unknown documentation type: $DOC_TYPE"
            exit 1
            ;;
    esac

    # Convert to HTML if requested
    if [[ "$OUTPUT_FORMAT" == "html" ]]; then
        convert_to_html
    fi

    log_info "Documentation generation complete!"
    log_info "Output directory: $OUTPUT_DIR"
    log_info ""
    log_info "Next steps:"
    log_info "  1. Review generated documentation"
    log_info "  2. Use Claude Code to fill in detailed content"
    log_info "  3. Customize for your project"
}

# Run main function
main "$@"
