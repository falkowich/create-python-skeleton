# This is my personal python project creator.

This repository provides a simple shell script, `create-skeleton.sh`, to scaffold clean, secure, and type-safe Python CLI projects 

It uses `uv` as the dependency manager and sets up my development environment with strong defaults for:

- Linting (ruff, black, isort)
- Typing (mypy)
- Security (pip-audit, bandit)
- CLI structure (click-based)
- Git integration (with a "batman" first commit)
- `pyproject.toml` with good defaults

---

## Usage

```bash
./create-skeleton.sh my-project-name
```

This will create a directory:

```
my-project-name/
├── Makefile
├── pyproject.toml
├── README.md
├── .gitignore           # from GitHub's canonical Python.gitignore
├── my_project_name/
│   ├── main.py
│   └── py.typed
```

Then:

```bash
cd my-project-name
make install
make check
.venv/bin/my-project-name  # runs your CLI
```

---

## Included Dev Tools

All configured via `pyproject.toml`:

- `ruff`, `black`, `isort` — for formatting and linting
- `mypy` — strict typing enforcement
- `pip-audit` — dependency vulnerability scanning
- `bandit` — static security checks
- `pyment`, `ptpython` — optional extras

---

## Git Integration

- Initializes a Git repo (`git init`)
- Downloads and applies the latest [`Python.gitignore`](https://github.com/github/gitignore/blob/main/Python.gitignore)
- Makes the first commit with the message:

```
batman
```

---

## Philosophy

- No code leaves your machine without you knowing.
- No unnecessary runtime dependencies.
- One `Makefile` to validate everything before you commit.
- A CLI structure you can grow from.

---

## Requirements

- `uv` installed (`cargo install uv`)
- `bash`
- Internet access (for `.gitignore` fetch, optional)

---

## License

Unlicensed. Use it, fork it, break it, rename it.

