#!/usr/bin/env python3
from pathlib import Path
import mimetypes

ROOT = Path.cwd()
OUT_MD = ROOT / "COMBINED_PROJECT_CODE.md"
OUT_TXT = ROOT / "COMBINED_PROJECT_CODE.txt"

SKIP_DIRS = {
    ".git",
    ".venv",
    "venv",
    "__pycache__",
    ".pytest_cache",
    ".mypy_cache",
    ".ruff_cache",
    "node_modules",
    "dist",
    "build",
    ".next",
    ".cache",
    "coverage",
    "logs",
    "tmp",
    "temp",
    ".idea",
    ".vscode",
}

SKIP_FILES = {
    "COMBINED_PROJECT_CODE.md",
    "COMBINED_PROJECT_CODE.txt",
    "combine_project_code.py",
    "package-lock.json",
    "yarn.lock",
    "pnpm-lock.yaml",
}

CODE_EXTENSIONS = {
    ".py": "python",
    ".lua": "lua",
    ".luau": "lua",
    ".js": "javascript",
    ".jsx": "jsx",
    ".ts": "typescript",
    ".tsx": "tsx",
    ".json": "json",
    ".yml": "yaml",
    ".yaml": "yaml",
    ".toml": "toml",
    ".ini": "ini",
    ".cfg": "ini",
    ".env": "bash",
    ".example": "text",
    ".sh": "bash",
    ".bash": "bash",
    ".zsh": "zsh",
    ".ps1": "powershell",
    ".bat": "bat",
    ".cmd": "bat",
    ".html": "html",
    ".css": "css",
    ".md": "markdown",
    ".sql": "sql",
    ".dockerfile": "dockerfile",
    ".Dockerfile": "dockerfile",
}

INCLUDE_NAMES = {
    "Dockerfile",
    "Makefile",
    "Procfile",
    ".env.example",
    ".gitignore",
    "requirements.txt",
    "pyproject.toml",
    "package.json",
    "tsconfig.json",
    "vite.config.ts",
    "vite.config.js",
    "README.md",
}

MAX_FILE_BYTES = 400_000


def should_skip(path: Path) -> bool:
    parts = set(path.parts)

    if parts & SKIP_DIRS:
        return True

    if path.name in SKIP_FILES:
        return True

    if path.name in INCLUDE_NAMES:
        return False

    if path.suffix in CODE_EXTENSIONS:
        return False

    return True


def is_probably_binary(path: Path) -> bool:
    try:
        chunk = path.read_bytes()[:4096]
        return b"\0" in chunk
    except Exception:
        return True


def lang_for(path: Path) -> str:
    if path.name == "Dockerfile":
        return "dockerfile"
    if path.name == "Makefile":
        return "makefile"
    return CODE_EXTENSIONS.get(path.suffix, "text")


def safe_read(path: Path) -> str:
    data = path.read_bytes()

    if len(data) > MAX_FILE_BYTES:
        return (
            f"[SKIPPED: file too large, {len(data)} bytes. "
            f"Limit is {MAX_FILE_BYTES} bytes.]"
        )

    return data.decode("utf-8", errors="replace")


def collect_files():
    files = []
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        if should_skip(path):
            continue
        if is_probably_binary(path):
            continue
        files.append(path)

    return sorted(files, key=lambda p: str(p.relative_to(ROOT)).lower())


def main():
    files = collect_files()

    md_parts = [
        "# Combined Project Code",
        "",
        f"Root: `{ROOT}`",
        f"Files included: `{len(files)}`",
        "",
        "---",
        "",
    ]

    txt_parts = [
        "COMBINED PROJECT CODE",
        f"Root: {ROOT}",
        f"Files included: {len(files)}",
        "=" * 80,
        "",
    ]

    for path in files:
        rel = path.relative_to(ROOT)
        content = safe_read(path)
        lang = lang_for(path)

        md_parts.append(f"## File: `{rel}`")
        md_parts.append("")
        md_parts.append(f"```{lang}")
        md_parts.append(content.rstrip())
        md_parts.append("```")
        md_parts.append("")

        txt_parts.append(f"\n{'=' * 80}")
        txt_parts.append(f"FILE: {rel}")
        txt_parts.append(f"{'=' * 80}\n")
        txt_parts.append(content.rstrip())
        txt_parts.append("")

    OUT_MD.write_text("\n".join(md_parts), encoding="utf-8")
    OUT_TXT.write_text("\n".join(txt_parts), encoding="utf-8")

    print("✅ Combined project code created:")
    print(f" - {OUT_MD}")
    print(f" - {OUT_TXT}")
    print(f"📦 Files included: {len(files)}")


if __name__ == "__main__":
    main()
