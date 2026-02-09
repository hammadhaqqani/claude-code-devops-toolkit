#!/bin/bash

# bulk-review.sh
# Review multiple files or directories using Claude Code
#
# Usage: ./bulk-review.sh [options]
#
# Options:
#   -d, --directory DIR    Directory to review (default: current directory)
#   -f, --files FILES      Comma-separated list of files to review
#   -p, --prompt FILE      Prompt file to use (default: security-review.md)
#   -o, --output FILE      Output file for review report (default: review-report.md)
#   -t, --type TYPE        File type filter (terraform, kubernetes, python, all)
#   -e, --exclude PATTERN  Exclude files matching pattern
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
TARGET_DIR="."
FILES=""
PROMPT_FILE="$REPO_ROOT/prompts/security-review.md"
OUTPUT_FILE="review-report.md"
FILE_TYPE="all"
EXCLUDE_PATTERN=""

# Function to display help
show_help() {
    cat << EOF
Bulk Review Script for Claude Code

Usage: $0 [options]

Options:
  -d, --directory DIR    Directory to review (default: current directory)
  -f, --files FILES      Comma-separated list of files to review
  -p, --prompt FILE      Prompt file to use (default: security-review.md)
  -o, --output FILE      Output file for review report (default: review-report.md)
  -t, --type TYPE        File type filter: terraform, kubernetes, python, all (default: all)
  -e, --exclude PATTERN  Exclude files matching pattern (glob)
  -h, --help            Show this help message

Examples:
  $0 -d ./infrastructure -t terraform
  $0 -f main.tf,variables.tf -p prompts/debugging.md
  $0 -d ./k8s -t kubernetes -e "*.bak"
  $0 -d . -o comprehensive-review.md

Note: This script generates a review report. Actual Claude Code integration
      would require Claude Code CLI or API access.

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
                TARGET_DIR="$2"
                shift 2
                ;;
            -f|--files)
                FILES="$2"
                shift 2
                ;;
            -p|--prompt)
                PROMPT_FILE="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -t|--type)
                FILE_TYPE="$2"
                shift 2
                ;;
            -e|--exclude)
                EXCLUDE_PATTERN="$2"
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

# Function to get file extension
get_file_type() {
    local file="$1"
    local ext="${file##*.}"
    case "$ext" in
        tf|tfvars)
            echo "terraform"
            ;;
        yaml|yml)
            if grep -q "apiVersion:\|kind:" "$file" 2>/dev/null; then
                echo "kubernetes"
            else
                echo "yaml"
            fi
            ;;
        py)
            echo "python"
            ;;
        sh|bash)
            echo "shell"
            ;;
        *)
            echo "other"
            ;;
    esac
}

# Function to find files
find_files() {
    local dir="$1"
    local type_filter="$2"
    local exclude="$3"
    local found_files=()

    if [[ -n "$FILES" ]]; then
        # Use specified files
        IFS=',' read -ra FILE_ARRAY <<< "$FILES"
        for file in "${FILE_ARRAY[@]}"; do
            file=$(echo "$file" | xargs) # trim whitespace
            if [[ -f "$file" ]]; then
                found_files+=("$file")
            elif [[ -f "$dir/$file" ]]; then
                found_files+=("$dir/$file")
            else
                log_warn "File not found: $file"
            fi
        done
    else
        # Find files in directory
        while IFS= read -r -d '' file; do
            local file_type=$(get_file_type "$file")
            
            # Apply type filter
            if [[ "$type_filter" != "all" ]] && [[ "$file_type" != "$type_filter" ]]; then
                continue
            fi
            
            # Apply exclude pattern
            if [[ -n "$exclude" ]] && [[ "$file" == *$exclude* ]]; then
                continue
            fi
            
            found_files+=("$file")
        done < <(find "$dir" -type f \( -name "*.tf" -o -name "*.tfvars" -o -name "*.yaml" -o -name "*.yml" -o -name "*.py" -o -name "*.sh" \) -print0 2>/dev/null || true)
    fi

    printf '%s\n' "${found_files[@]}"
}

# Function to generate review report
generate_report() {
    local files_array=("$@")
    local prompt_content=""
    local report_date=$(date '+%Y-%m-%d %H:%M:%S')

    log_info "Generating review report..."

    # Read prompt file if it exists
    if [[ -f "$PROMPT_FILE" ]]; then
        prompt_content=$(cat "$PROMPT_FILE")
        log_info "Using prompt file: $PROMPT_FILE"
    else
        log_warn "Prompt file not found: $PROMPT_FILE"
        prompt_content="# Security Review

This is a bulk security review of the specified files.
"
    fi

    # Generate report header
    cat > "$OUTPUT_FILE" << EOF
# Bulk Review Report

**Generated:** $report_date
**Directory:** $TARGET_DIR
**Files Reviewed:** ${#files_array[@]}
**Prompt File:** $PROMPT_FILE
**File Type Filter:** $FILE_TYPE

---

## Summary

This report contains a review of ${#files_array[@]} file(s) using the specified prompt template.

## Files Reviewed

EOF

    # List all files
    for file in "${files_array[@]}"; do
        echo "- \`$file\`" >> "$OUTPUT_FILE"
    done

    cat >> "$OUTPUT_FILE" << EOF

---

## Review Template

\`\`\`
$prompt_content
\`\`\`

---

## File-by-File Review

EOF

    # Generate review sections for each file
    local file_num=1
    for file in "${files_array[@]}"; do
        log_info "Processing file $file_num/${#files_array[@]}: $file"
        
        cat >> "$OUTPUT_FILE" << EOF

### File $file_num: \`$file\`

**File Type:** $(get_file_type "$file")
**Size:** $(wc -c < "$file" | xargs) bytes
**Lines:** $(wc -l < "$file" | xargs)

**Review Notes:**
- [ ] Security review completed
- [ ] Best practices checked
- [ ] Configuration validated

**Issues Found:**
- _Review this file using Claude Code with the prompt template above_

**Recommendations:**
- _Add recommendations after review_

---

EOF
        file_num=$((file_num + 1))
    done

    cat >> "$OUTPUT_FILE" << EOF

## Next Steps

1. Review each file using Claude Code with the provided prompt template
2. Update the "Issues Found" and "Recommendations" sections for each file
3. Prioritize fixes based on severity
4. Track remediation progress

## Notes

This is a template report. Actual review should be performed using Claude Code
with the specified prompt file. Replace placeholder content with actual review
findings.

EOF

    log_info "Report generated: $OUTPUT_FILE"
}

# Function to display statistics
show_stats() {
    local files_array=("$@")
    local terraform_count=0
    local k8s_count=0
    local python_count=0
    local other_count=0

    for file in "${files_array[@]}"; do
        case $(get_file_type "$file") in
            terraform)
                terraform_count=$((terraform_count + 1))
                ;;
            kubernetes)
                k8s_count=$((k8s_count + 1))
                ;;
            python)
                python_count=$((python_count + 1))
                ;;
            *)
                other_count=$((other_count + 1))
                ;;
        esac
    done

    echo
    log_info "Review Statistics:"
    echo "  Total files: ${#files_array[@]}"
    echo "  Terraform files: $terraform_count"
    echo "  Kubernetes files: $k8s_count"
    echo "  Python files: $python_count"
    echo "  Other files: $other_count"
    echo
}

# Main execution
main() {
    parse_args "$@"

    # Validate directory
    if [[ ! -d "$TARGET_DIR" ]]; then
        log_error "Directory not found: $TARGET_DIR"
        exit 1
    fi

    log_info "Starting bulk review..."
    log_info "Target directory: $TARGET_DIR"
    log_info "File type filter: $FILE_TYPE"
    log_info "Output file: $OUTPUT_FILE"

    # Find files
    mapfile -t FOUND_FILES < <(find_files "$TARGET_DIR" "$FILE_TYPE" "$EXCLUDE_PATTERN")

    if [[ ${#FOUND_FILES[@]} -eq 0 ]]; then
        log_warn "No files found matching criteria"
        exit 0
    fi

    # Show statistics
    show_stats "${FOUND_FILES[@]}"

    # Generate report
    generate_report "${FOUND_FILES[@]}"

    log_info "Bulk review complete!"
    log_info "Review report saved to: $OUTPUT_FILE"
}

# Run main function
main "$@"
