# Python DevOps Project Guidelines

This document provides context and conventions for Python code generation and DevOps tooling in this project.

## Project Context

This is a Python-based DevOps project focusing on infrastructure automation, tooling, and cloud operations. Code should follow Python best practices, be well-tested, and production-ready.

## Code Style and Conventions

### Python Version

- **Minimum**: Python 3.10
- **Target**: Python 3.11 or 3.12
- Use type hints for all functions and methods
- Use f-strings for string formatting (Python 3.6+)

### Code Style

Follow PEP 8 with these specific conventions:

- **Line length**: Maximum 100 characters (use `black` with `--line-length=100`)
- **Imports**: Use absolute imports, group by standard library, third-party, local
- **Naming**: 
  - Functions/variables: `snake_case`
  - Classes: `PascalCase`
  - Constants: `UPPER_SNAKE_CASE`
  - Private: Prefix with `_single_underscore`

### File Organization

```
project/
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── main.py
│       └── modules/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── scripts/
│   └── deployment.sh
├── requirements.txt
├── requirements-dev.txt
├── pyproject.toml
├── setup.py
└── README.md
```

## Type Hints

Always use type hints:

```python
from typing import List, Dict, Optional, Union
from pathlib import Path

def process_files(
    file_paths: List[Path],
    config: Dict[str, str],
    timeout: Optional[int] = None
) -> Dict[str, Union[str, int]]:
    """Process multiple files with given configuration."""
    pass
```

## Error Handling

### Exception Handling

- Use specific exceptions, not bare `except:`
- Log exceptions with context
- Re-raise with `raise ... from` to preserve traceback

```python
import logging

logger = logging.getLogger(__name__)

try:
    result = risky_operation()
except SpecificError as e:
    logger.error(f"Operation failed: {e}", exc_info=True)
    raise ProcessingError("Failed to process") from e
```

### Custom Exceptions

Define project-specific exceptions:

```python
class ProjectError(Exception):
    """Base exception for project-specific errors."""
    pass

class ConfigurationError(ProjectError):
    """Raised when configuration is invalid."""
    pass

class ValidationError(ProjectError):
    """Raised when validation fails."""
    pass
```

## Logging

### Logging Configuration

Use structured logging with appropriate levels:

```python
import logging
import sys
from logging.handlers import RotatingFileHandler

def setup_logging(log_level: str = "INFO", log_file: Optional[Path] = None):
    """Configure application logging."""
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    handlers = [logging.StreamHandler(sys.stdout)]
    
    if log_file:
        file_handler = RotatingFileHandler(
            log_file, maxBytes=10*1024*1024, backupCount=5
        )
        file_handler.setFormatter(formatter)
        handlers.append(file_handler)
    
    logging.basicConfig(
        level=getattr(logging, log_level.upper()),
        handlers=handlers,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
```

### Logging Best Practices

- Use appropriate log levels: DEBUG, INFO, WARNING, ERROR, CRITICAL
- Include context in log messages
- Don't log sensitive information (passwords, tokens, etc.)
- Use structured logging for production (JSON format)

## Testing Requirements

### Testing Framework

- Use `pytest` as the testing framework
- Aim for >80% code coverage
- Write unit tests for all functions
- Write integration tests for critical paths

### Test Structure

```python
# tests/unit/test_module.py
import pytest
from src.package_name.module import function_to_test

def test_function_success():
    """Test successful execution."""
    result = function_to_test(input_data)
    assert result == expected_output

def test_function_failure():
    """Test error handling."""
    with pytest.raises(ExpectedError):
        function_to_test(invalid_input)

@pytest.fixture
def sample_data():
    """Fixture providing test data."""
    return {"key": "value"}
```

### Test Commands

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html --cov-report=term

# Run specific test file
pytest tests/unit/test_module.py

# Run with verbose output
pytest -v

# Run only fast tests
pytest -m "not slow"
```

## Dependency Management

### Requirements Files

- `requirements.txt`: Production dependencies (pinned versions)
- `requirements-dev.txt`: Development dependencies
- Use `pip-tools` for dependency management

### Virtual Environment

Always use virtual environments:

```bash
# Create virtual environment
python -m venv venv

# Activate (Linux/Mac)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

### Poetry (Alternative)

If using Poetry:

```toml
[tool.poetry]
name = "project-name"
version = "0.1.0"
description = "Project description"

[tool.poetry.dependencies]
python = "^3.10"
requests = "^2.31.0"

[tool.poetry.dev-dependencies]
pytest = "^7.4.0"
black = "^23.7.0"
mypy = "^1.5.0"
```

## Code Quality Tools

### Pre-commit Hooks

Use pre-commit hooks for code quality:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.7.0
    hooks:
      - id: black
  - repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.5.1
    hooks:
      - id: mypy
```

### Linting and Formatting

```bash
# Format code with black
black src/ tests/

# Lint with flake8
flake8 src/ tests/

# Type checking with mypy
mypy src/

# Sort imports
isort src/ tests/
```

## Configuration Management

### Environment Variables

Use environment variables for configuration:

```python
import os
from typing import Optional

def get_config(key: str, default: Optional[str] = None) -> str:
    """Get configuration from environment variable."""
    value = os.getenv(key, default)
    if value is None:
        raise ConfigurationError(f"Required config {key} not set")
    return value

# Usage
DATABASE_URL = get_config("DATABASE_URL")
API_KEY = get_config("API_KEY")
```

### Configuration Files

Use YAML or TOML for complex configurations:

```python
import yaml
from pathlib import Path
from typing import Dict, Any

def load_config(config_path: Path) -> Dict[str, Any]:
    """Load configuration from YAML file."""
    with open(config_path) as f:
        return yaml.safe_load(f)
```

## CLI Development

### Argument Parsing

Use `argparse` or `click` for CLI tools:

```python
import argparse

def create_parser() -> argparse.ArgumentParser:
    """Create command-line argument parser."""
    parser = argparse.ArgumentParser(
        description="Tool description",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "--config",
        type=Path,
        required=True,
        help="Path to configuration file"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose output"
    )
    return parser

def main():
    parser = create_parser()
    args = parser.parse_args()
    # Process arguments
```

## Async Programming

When using async/await:

```python
import asyncio
import aiohttp
from typing import List

async def fetch_url(session: aiohttp.ClientSession, url: str) -> str:
    """Fetch content from URL asynchronously."""
    async with session.get(url) as response:
        return await response.text()

async def fetch_multiple(urls: List[str]) -> List[str]:
    """Fetch multiple URLs concurrently."""
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_url(session, url) for url in urls]
        return await asyncio.gather(*tasks)
```

## Docker Integration

### Dockerfile Best Practices

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ ./src/

# Run as non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

CMD ["python", "-m", "src.main"]
```

## Deployment Patterns

### Application Structure

```python
# src/package_name/main.py
import logging
import sys
from pathlib import Path

from .config import load_config
from .app import Application

logger = logging.getLogger(__name__)

def main():
    """Main entry point."""
    try:
        config = load_config(Path("config.yaml"))
        app = Application(config)
        app.run()
    except KeyboardInterrupt:
        logger.info("Application interrupted by user")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Application error: {e}", exc_info=True)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Common Commands

```bash
# Setup development environment
python -m venv venv
source venv/bin/activate
pip install -r requirements-dev.txt
pre-commit install

# Run tests
pytest

# Format code
black src/ tests/
isort src/ tests/

# Lint
flake8 src/ tests/
mypy src/

# Build package
python setup.py sdist bdist_wheel

# Run application
python -m src.package_name.main
```

## Documentation

- Use docstrings for all modules, classes, and functions (Google or NumPy style)
- Include type information in docstrings
- Document command-line arguments
- Keep README.md updated with setup and usage instructions

## Additional Resources

- [PEP 8 Style Guide](https://pep8.org/)
- [Python Type Hints](https://docs.python.org/3/library/typing.html)
- [pytest Documentation](https://docs.pytest.org/)
- [Black Code Formatter](https://black.readthedocs.io/)
