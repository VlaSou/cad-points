from __future__ import annotations

import json
import re
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
PACKAGE_JSON = REPO_ROOT / "package.json"
LSP_PATH = REPO_ROOT / "src" / "CadPoints.bundle" / "Contents" / "LISP" / "cadpoints.lsp"
PACKAGE_CONTENTS = REPO_ROOT / "src" / "CadPoints.bundle" / "PackageContents.xml"
ROOT_README = REPO_ROOT / "README.md"
CZ_README = REPO_ROOT / "README.cs-CZ.md"
BUNDLE_README = REPO_ROOT / "src" / "CadPoints.bundle" / "README.md"
HELP_HTML = REPO_ROOT / "src" / "CadPoints.bundle" / "Contents" / "Resources" / "help.html"


def bump_semver(version: str, bump_type: str) -> str:
    match = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)", version)
    if not match:
        raise ValueError(f"Unsupported version format: {version}")

    major = int(match.group(1))
    minor = int(match.group(2))
    patch = int(match.group(3))

    if bump_type == "major":
        major += 1
        minor = 0
        patch = 0
    elif bump_type == "minor":
        minor += 1
        patch = 0
    else:
        patch += 1

    return f"{major}.{minor}.{patch}"


def replace_first(text: str, search: str, replacement: str, label: str) -> str:
    if search not in text:
        raise ValueError(f"Missing {label}: {search}")
    return text.replace(search, replacement, 1)


def main() -> int:
    bump_type = (sys.argv[1] if len(sys.argv) > 1 else "patch").lower()
    if bump_type not in {"patch", "minor", "major"}:
        print("Usage: py -3 scripts/version.py [patch|minor|major]")
        return 1

    package_json = json.loads(PACKAGE_JSON.read_text(encoding="utf-8"))
    current_version = package_json["version"]
    next_version = bump_semver(current_version, bump_type)
    next_zip_slug = next_version.replace(".", "_")

    package_json["version"] = next_version
    PACKAGE_JSON.write_text(json.dumps(package_json, indent=2) + "\n", encoding="utf-8")

    lsp_text = LSP_PATH.read_text(encoding="utf-8")
    lsp_text = replace_first(
        lsp_text,
        f'(setq *cadpoints-version* "{current_version}")',
        f'(setq *cadpoints-version* "{next_version}")',
        "cadpoints.lsp version",
    )
    LSP_PATH.write_text(lsp_text, encoding="utf-8")

    package_contents_text = PACKAGE_CONTENTS.read_text(encoding="utf-8")
    package_contents_text = replace_first(
        package_contents_text,
        f'AppVersion="{current_version}"',
        f'AppVersion="{next_version}"',
        "PackageContents.xml AppVersion",
    )
    PACKAGE_CONTENTS.write_text(package_contents_text, encoding="utf-8")

    for path in [ROOT_README, CZ_README, BUNDLE_README]:
        text = path.read_text(encoding="utf-8")
        path.write_text(text.replace(current_version, next_version), encoding="utf-8")

    help_html = HELP_HTML.read_text(encoding="utf-8")
    HELP_HTML.write_text(
        help_html.replace(f"CadPoints {current_version}", f"CadPoints {next_version}"),
        encoding="utf-8",
    )

    print(f"Bumped CadPoints {current_version} -> {next_version}")
    print(f"Release ZIP name will use v{next_zip_slug}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

