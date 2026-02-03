#!/usr/bin/env bash
# create-skeleton.sh - Modern Python project scaffolder
# Usage: ./create-skeleton.sh PROJECT_NAME [--api] [--db]

set -euo pipefail

PROJECT_NAME="${1:-}"
WITH_API=false
WITH_DB=false

# Parse flags
shift || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --api) WITH_API=true; shift ;;
        --db)  WITH_DB=true; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$PROJECT_NAME" ]]; then
    cat << 'USAGE'
Usage: create-skeleton.sh PROJECT_NAME [OPTIONS]

Options:
  --api    Include httpx, pydantic-settings for API work
  --db     Include SQLAlchemy 2.x, Alembic, psycopg

Examples:
  create-skeleton.sh my-tool
  create-skeleton.sh my-api --api
  create-skeleton.sh my-service --db
  create-skeleton.sh my-app --api --db
USAGE
    exit 1
fi

if [[ -d "$PROJECT_NAME" ]]; then
    echo "Error: Directory '$PROJECT_NAME' already exists"
    exit 1
fi

PACKAGE_NAME="${PROJECT_NAME//-/_}"

echo "Creating Python project: $PROJECT_NAME"
echo "Package name: $PACKAGE_NAME"
[[ $WITH_API == true ]] && echo "Including API dependencies (httpx, pydantic-settings)"
[[ $WITH_DB == true ]] && echo "Including database dependencies (SQLAlchemy 2.x, Alembic)"
echo ""

# Create src-layout structure
mkdir -p "$PROJECT_NAME/src/$PACKAGE_NAME"
cd "$PROJECT_NAME"

# Create py.typed marker for PEP 561 compliance
touch "src/$PACKAGE_NAME/py.typed"

# Create main.py
cat > "src/$PACKAGE_NAME/main.py" << 'EOPY'
"""Main CLI entrypoint."""
import click
from loguru import logger


@click.command()
@click.option("--verbose", "-v", is_flag=True, help="Enable verbose logging")
def main(verbose: bool) -> None:
    """Your CLI tool."""
    if verbose:
        logger.enable("")
    else:
        logger.disable("")
    
    logger.info("Starting {}", __package__)
    click.echo("CLI is running")


if __name__ == "__main__":
    main()
EOPY

# Build dependencies list
DEPS=(
    "click"
    "loguru"
    "rich"
)

[[ $WITH_API == true ]] && DEPS+=("httpx" "pydantic-settings" "python-dotenv")
[[ $WITH_DB == true ]] && DEPS+=("sqlalchemy>=2.0" "alembic" "psycopg[binary]")

DEPS_STR=$(printf '"%s",' "${DEPS[@]}")
DEPS_STR="${DEPS_STR%,}"

# Create pyproject.toml
cat > pyproject.toml << EOTOML
[project]
name = "$PROJECT_NAME"
version = "0.1.0"
description = "A Python CLI tool"
readme = "README.md"
requires-python = ">=3.13"
dependencies = [
    $DEPS_STR,
]

[project.scripts]
$PACKAGE_NAME = "$PACKAGE_NAME.main:main"

[tool.uv]
package = true

[dependency-groups]
dev = [
    "ruff",
    "mypy",
    "pip-audit",
    "bandit",
    "pytest",
    "pytest-cov",
    "ptpython",
]

# Ruff configuration - replaces black, isort, flake8
[tool.ruff]
target-version = "py313"
src = ["src"]
exclude = [".venv", "__pycache__", ".mypy_cache", ".pytest_cache", "dist"]
line-length = 100

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "F",      # pyflakes
    "W",      # pycodestyle warnings
    "I",      # isort
    "UP",     # pyupgrade
    "B",      # flake8-bugbear
    "C4",     # flake8-comprehensions
    "SIM",    # flake8-simplify
    "PL",     # pylint
    "RUF",    # ruff-specific rules
]
ignore = [
    "E501",   # Line too long - handled by formatter
]

[tool.ruff.lint.isort]
combine-as-imports = true
known-first-party = ["$PACKAGE_NAME"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"

# Mypy configuration
[tool.mypy]
python_version = "3.13"
warn_unused_configs = true
warn_redundant_casts = true
warn_unused_ignores = true
disallow_untyped_defs = true
no_implicit_optional = true
check_untyped_defs = true
strict_optional = true
files = ["src"]

# pytest configuration
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
addopts = "--cov=$PACKAGE_NAME --cov-report=term-missing"
EOTOML

# Create Makefile
cat > Makefile << 'EOMAKE'
.PHONY: install check format lint type audit security test clean

install:
	uv sync

format:
	uv run ruff format .
	uv run ruff check --fix .

lint:
	uv run ruff check .

type:
	uv run mypy .

audit:
	uv run pip-audit

security:
	uv run bandit -r src/ -ll

test:
	uv run pytest

check: format lint type audit security
	@echo "All checks passed"

clean:
	rm -rf .venv dist .pytest_cache .mypy_cache .ruff_cache
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
EOMAKE

# Create README.md
cat > README.md << EORM
# $PROJECT_NAME

Modern Python CLI tool.

## Stack

- **uv** - Fast dependency management
- **Ruff** - Linting and formatting (replaces black + isort + flake8)
- **mypy** - Strict type checking
- **click** - CLI framework
- **loguru** - Logging
- **rich** - Terminal UI

## Quick Start

\`\`\`bash
# Install dependencies
make install

# Run the CLI
uv run $PACKAGE_NAME --help
\`\`\`

## Development

\`\`\`bash
# Format code
make format

# Run all checks
make check

# Run tests
make test

# Clean build artifacts
make clean
\`\`\`

## Project Structure

\`\`\`
$PROJECT_NAME/
├── src/
│   └── $PACKAGE_NAME/
│       ├── main.py      # CLI entrypoint
│       └── py.typed     # PEP 561 type marker
├── tests/
├── pyproject.toml       # Project configuration
├── Makefile             # Development commands
└── README.md
\`\`\`

## Philosophy

- Default configurations over custom optimization
- Maintainability over perfection
- Standard tools over exotic dependencies
- Type safety enforced via mypy strict mode
- src-layout for proper packaging

## Adding Dependencies

\`\`\`bash
# Runtime dependency
uv add package-name

# Development dependency
uv add --dev package-name
\`\`\`

## Security

\`\`\`bash
# Audit dependencies for known vulnerabilities
make audit

# Static security analysis
make security
\`\`\`
EORM

# Fetch Python.gitignore
echo "Fetching Python.gitignore from GitHub..."
if command -v curl &> /dev/null; then
    curl -sL https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore -o .gitignore
elif command -v wget &> /dev/null; then
    wget -q https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore -O .gitignore
else
    echo "Warning: curl/wget not found, creating basic .gitignore"
    cat > .gitignore << 'EOGI'
__pycache__/
*.py[cod]
*$py.class
.venv/
.pytest_cache/
.mypy_cache/
.ruff_cache/
dist/
*.egg-info/
.DS_Store
EOGI
fi

# Initialize Git
echo "Initializing Git repository..."
git init -q
git add .
git commit -q -m "batman"

# Initialize uv environment
echo "Initializing uv environment..."
uv sync --quiet

echo ""
echo "Project created successfully"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  make check"
echo "  uv run $PACKAGE_NAME"
echo ""
