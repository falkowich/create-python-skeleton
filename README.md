# create-python-skeleton

Bash script for scaffolding modern Python CLI projects with sensible defaults.

## Philosophy

- Standard configurations over custom optimization
- Maintainability over complexity
- Modern tooling with minimal dependencies
- src-layout for proper packaging
- Everything needed, nothing more

## Requirements

- bash
- git
- uv (install via: curl -LsSf https://astral.sh/uv/install.sh | sh)
- curl or wget (for fetching .gitignore)

## Usage
```bash
./create-skeleton.sh PROJECT_NAME [OPTIONS]
```

### Options

- `--api` - Include httpx and pydantic-settings for API work
- `--db` - Include SQLAlchemy 2.x, Alembic, and psycopg for database work

### Examples
```bash
# Basic CLI tool
./create-skeleton.sh my-tool

# API client/server
./create-skeleton.sh my-api --api

# Database-backed service
./create-skeleton.sh my-service --db

# Full-stack application
./create-skeleton.sh my-app --api --db
```

## What Gets Created
```
project-name/
├── src/
│   └── project_name/
│       ├── main.py           # CLI entrypoint with click
│       └── py.typed          # PEP 561 type marker
├── tests/
├── pyproject.toml            # uv-native configuration
├── Makefile                  # Development commands
├── README.md                 # Project documentation
└── .gitignore                # Python.gitignore from GitHub
```

### Initial Git Commit

The script initializes a git repository with the message "batman".

## Technology Stack

### Core Dependencies

- **click** - CLI framework
- **loguru** - Better logging than stdlib
- **rich** - Terminal formatting

### Optional Dependencies

With `--api`:
- **httpx** - Modern async HTTP client
- **pydantic-settings** - Configuration management
- **python-dotenv** - Environment variables

With `--db`:
- **SQLAlchemy 2.x** - Database ORM
- **Alembic** - Database migrations
- **psycopg[binary]** - PostgreSQL adapter

### Development Tools

- **Ruff** - Fast Python linter and formatter (replaces black + isort + flake8)
- **mypy** - Static type checker (strict mode)
- **pip-audit** - Dependency vulnerability scanner
- **bandit** - Security issue finder
- **pytest** - Test framework
- **pytest-cov** - Coverage reporting
- **ptpython** - Better REPL

## Design Decisions

### Why src-layout?

- Recommended by PyPA (Python Packaging Authority)
- Prevents accidental imports of uninstalled code
- Forces proper packaging from day one
- Industry standard for modern Python projects

### Why uv?

- Native Python 3.13 support
- Simple dependency management
- No complex lock files to maintain

### Why Ruff?

- Replaces black, isort, and flake8 in one tool
- Actively maintained
- Good enough defaults

### Why Not X?

**No pre-commit hooks**
- Adds complexity
- Manual `make check` is sufficient
- Easy to add later if needed

**No Docker/containers**
- Not all projects need it
- Easy to add when required
- Keeps skeleton simple

**No tox/nox**
- Single Python version target (3.13)
- CI/CD handles multi-version if needed
- Reduces local complexity

## Makefile Commands
```bash
make install   # Install dependencies with uv
make format    # Format code with ruff
make lint      # Lint code with ruff
make type      # Type check with mypy
make audit     # Check for vulnerabilities
make security  # Run bandit security checks
make test      # Run pytest
make check     # Run all checks
make clean     # Remove build artifacts
```

## Philosophy

This scaffolder follows the principle of "good enough" over "perfect":

- Default configurations work for 90% of use cases
- Easy for the next person to understand
- Standard tools over exotic dependencies
- Maintainability over optimization
- Simple over clever

If you need optimization, you'll know when. Start simple.

## src-layout vs flat-layout

This tool uses src-layout (recommended by PyPA) instead of the older flat-layout:

**src-layout (modern):**
```
project/
├── src/
│   └── package/
│       └── module.py
└── pyproject.toml
```

**flat-layout (legacy):**
```
project/
├── package/
│   └── module.py
└── pyproject.toml
```

Benefits of src-layout:
- Prevents accidental imports from uninstalled package
- Forces testing against installed code
- Avoids "works locally but not when installed" bugs

## Comparison with Other Tools

| Feature | create-skeleton | cookiecutter | poetry new |
|---------|----------------|--------------|------------|
| Speed | Fast (bash) | Slow (Python) | Medium |
| Dependencies | None (bash + uv) | Many | poetry |
| Complexity | Low | High | Medium |
| Customization | Edit script | Templates | Limited |
| Maintenance | Single file | Template repo | Tool updates |
| Layout | src-layout | Configurable | flat-layout |

## Installation
```bash
# Download
curl -O https://raw.githubusercontent.com/falkowich/create-python-skeleton/main/create-skeleton.sh

# Make executable
chmod +x create-skeleton.sh

# Optional: Move to PATH
mv create-skeleton.sh ~/bin/create-skeleton
```

## Requirements for Generated Projects

- Python 3.13+
- Linux/macOS (Windows via WSL)

## Maintenance

The script uses standard Python .gitignore from GitHub's official repository. This ensures compatibility with common Python tooling without manual updates.

## License

Public domain. Use it, modify it, distribute it.

## Contributing

This is a personal tool. Fork it and make it yours.

## Anti-Goals

This script explicitly does NOT:
- Support multiple Python versions (use 3.13+)
- Include frontend frameworks
- Add CI/CD configurations (too project-specific)
- Create virtual environments manually (uv handles this)
- Add pre-commit hooks (manual checks via Makefile)
- Include Docker/containers (add when needed)
- Use flat-layout (src-layout is modern standard)

Keep it simple.

## References

- [PyPA src-layout documentation](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/)
- [uv documentation](https://docs.astral.sh/uv/)
- [Ruff documentation](https://docs.astral.sh/ruff/)
