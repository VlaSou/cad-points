from __future__ import annotations

import argparse
import json
import platform
import re
from datetime import datetime, timezone
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
PACKAGE_JSON = REPO_ROOT / "package.json"
PACKAGE_CONTENTS = REPO_ROOT / "src" / "CadPoints.bundle" / "PackageContents.xml"
LSP_PATH = REPO_ROOT / "src" / "CadPoints.bundle" / "Contents" / "LISP" / "cadpoints.lsp"
ROOT_README = REPO_ROOT / "README.md"
CZ_README = REPO_ROOT / "README.cs-CZ.md"
DIST_BUNDLE = REPO_ROOT / "dist" / "CadPoints.bundle"
RELEASES_DIR = REPO_ROOT / "releases"
INSTALLER = REPO_ROOT / "scripts" / "install_windows.bat"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def read_package_json() -> dict[str, object]:
    return json.loads(read_text(PACKAGE_JSON))


def extract_version(text: str, pattern: str) -> str | None:
    match = re.search(pattern, text)
    if match:
        return match.group(1)
    return None


def collect_report() -> dict[str, object]:
    package_json = read_package_json()
    package_version = package_json.get("version", "")
    package_manager = package_json.get("packageManager", "")
    package_name = package_json.get("name", "")

    package_contents = read_text(PACKAGE_CONTENTS)
    lsp_text = read_text(LSP_PATH)

    version_checks = {
        "package.json": str(package_version),
        "PackageContents.xml": extract_version(package_contents, r'AppVersion="([^"]+)"'),
        "cadpoints.lsp": extract_version(lsp_text, r'\(setq \*cadpoints-version\* "([^"]+)"\)'),
    }

    version_values = list(version_checks.values())
    version_consistent = all(version_values) and len(set(version_values)) == 1
    missing_paths = [
        relative.as_posix()
        for relative in [
            Path("package.json"),
            Path("README.md"),
            Path("README.cs-CZ.md"),
            Path("scripts/diagnostics.py"),
            Path("scripts/install_windows.bat"),
            Path("src/CadPoints.bundle/PackageContents.xml"),
            Path("src/CadPoints.bundle/Contents/LISP/cadpoints.lsp"),
            Path("src/CadPoints.bundle/Contents/Test/example_test.dxf"),
            Path("src/CadPoints.bundle/Contents/Test/cadpoints_smoke_test.lsp"),
        ]
        if not (REPO_ROOT / relative).exists()
    ]

    release_zips = sorted(
        path.name for path in RELEASES_DIR.glob("CadPoints_LT_Plugin_v*.zip") if path.is_file()
    )

    return {
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "repo_root": str(REPO_ROOT),
        "platform": platform.platform(),
        "python": platform.python_version(),
        "package_name": package_name,
        "package_version": package_version,
        "package_manager": package_manager,
        "version_checks": version_checks,
        "version_consistent": version_consistent,
        "missing_paths": missing_paths,
        "source_bundle_exists": (REPO_ROOT / "src" / "CadPoints.bundle").exists(),
        "dist_bundle_exists": DIST_BUNDLE.exists(),
        "installer_exists": INSTALLER.exists(),
        "release_zips": release_zips,
    }


def render_text(report: dict[str, object]) -> str:
    lines: list[str] = []
    lines.append("CadPoints diagnostics report")
    lines.append(f"Generated: {report['generated_at']}")
    lines.append(f"Repository: {report['repo_root']}")
    lines.append(f"Platform: {report['platform']}")
    lines.append(f"Python: {report['python']}")
    lines.append("")
    lines.append("Package")
    lines.append(f"- name: {report['package_name']}")
    lines.append(f"- version: {report['package_version']}")
    lines.append(f"- package manager: {report['package_manager']}")
    lines.append("")
    lines.append("Version checks")
    for label, value in report["version_checks"].items():
        lines.append(f"- {label}: {value or 'MISSING'}")
    lines.append(f"- versions consistent: {'yes' if report['version_consistent'] else 'no'}")
    lines.append("")
    lines.append("Paths")
    lines.append(f"- src/CadPoints.bundle: {'yes' if report['source_bundle_exists'] else 'no'}")
    lines.append(f"- dist/CadPoints.bundle: {'yes' if report['dist_bundle_exists'] else 'no'}")
    lines.append(f"- scripts/install_windows.bat: {'yes' if report['installer_exists'] else 'no'}")
    if report["missing_paths"]:
        lines.append("- missing required paths:")
        for path in report["missing_paths"]:
            lines.append(f"  - {path}")
    else:
        lines.append("- missing required paths: none")
    lines.append("")
    lines.append("Tracked release ZIPs")
    if report["release_zips"]:
        for zip_name in report["release_zips"]:
            lines.append(f"- {zip_name}")
    else:
        lines.append("- none found")
    lines.append("")
    lines.append("What to send back")
    lines.append("- the full text of this report")
    lines.append("- if possible, save it with:")
    lines.append("  py -3 scripts/diagnostics.py > cadpoints-diagnostics.txt")
    lines.append("- in AutoCAD LT, also paste the command output for:")
    lines.append("  APPAUTOLOAD")
    lines.append("  APPAUTOLOADER")
    lines.append("  SECURELOAD")
    lines.append("  TRUSTEDPATHS")
    lines.append("  APPLOAD CadPoints.bundle\\Contents\\LISP\\cadpoints.lsp")
    lines.append("  CPSETTINGS")
    lines.append("  CPEXPORT")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Print a shareable CadPoints diagnostic report.")
    parser.add_argument("--json", action="store_true", help="Print JSON instead of human-readable text.")
    args = parser.parse_args()

    report = collect_report()
    if args.json:
        print(json.dumps(report, indent=2, ensure_ascii=False))
    else:
        print(render_text(report))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
