#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <project-name-kebab-case>"
  exit 1
fi

PROJECT="$1"
PACKAGE="${PROJECT//-/_}"

mkdir -p "$PROJECT/$PACKAGE"
cd "$PROJECT"

cat > pyproject.toml <<EOF
[project]
name = "$PROJECT"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "click",
    "loguru",
    "rich",
]

[tool.uv]
package = true
dev-dependencies = [
    "bandit",
    "black",
    "isort",
    "mypy",
    "pip-audit",
    "ptpython",
    "pyment",
    "ruff",
]

[tool.ruff]
exclude = [".venv", "__pycache__", ".mypy_cache", "output"]

[tool.mypy]
ignore_missing_imports = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
strict_optional = true
warn_unused_ignores = true

[project.scripts]
$PROJECT = "$PACKAGE.main:main"

[tool.setuptools.package-data]
$PACKAGE = ["py.typed"]
EOF

cat > Makefile <<'EOF'
VENV = .venv
UV = $(HOME)/.cargo/bin/uv
SRC = $(shell find . -maxdepth 1 -type d ! -name .venv ! -name . -exec basename {} \;)

BLACK = $(VENV)/bin/black
ISORT = $(VENV)/bin/isort
RUFF = $(VENV)/bin/ruff
MYPY = $(VENV)/bin/mypy
BANDIT = $(VENV)/bin/bandit
PYTEST = $(VENV)/bin/pytest
PIP_AUDIT = $(VENV)/bin/pip-audit

.PHONY: all install dev-install format lint lint-fix typecheck check-security check-safety test check ci validate

all: check test

install: $(VENV)
	$(UV) sync

dev-install: $(VENV)
	$(UV) sync --dev

$(VENV):
	python -m venv $(VENV)

format:
	$(BLACK) .
	$(ISORT) . --profile=black

lint:
	$(RUFF) check .

lint-fix:
	$(RUFF) check --fix .

typecheck:
	$(MYPY) $(SRC)

check-security:
	$(BANDIT) -x .venv/ -r $(SRC)

check-safety:
	$(PIP_AUDIT)

test:
	$(PYTEST) -v || echo "no tests yet"

check: format lint typecheck check-security check-safety

ci: check test

validate:
	@if [ -z "$(f)" ]; then \
		echo "Usage: make validate f=somefile.py"; \
		exit 1; \
	fi
	$(BLACK) $(f)
	$(ISORT) $(f) --profile=black
	$(RUFF) check $(f)
	$(MYPY) $(f)
EOF

cat > "$PACKAGE/main.py" <<EOF
def main() -> None:
    print("Hello from $PROJECT!")


if __name__ == "__main__":
    main()
EOF

touch "$PACKAGE/py.typed"
echo "# $PROJECT" > README.md
echo "Fetching Python.gitignore..."

curl -fsSL https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore -o .gitignore || {
    echo "Failed to download Python.gitignore. Falling back to .venv/"
    echo ".venv/" > .gitignore
}

git init -b main
git add .
git commit -m "batman"

