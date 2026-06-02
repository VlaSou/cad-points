from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
SOURCE_BUNDLE_DIR = REPO_ROOT / "src" / "CadPoints.bundle"
DIST_BUNDLE_DIR = REPO_ROOT / "dist" / "CadPoints.bundle"
RELEASES_DIR = REPO_ROOT / "releases"
INSTALLER_BAT = REPO_ROOT / "scripts" / "install_windows.bat"


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def package_version() -> str:
    package_text = read_text(SOURCE_BUNDLE_DIR / "PackageContents.xml")
    match = re.search(r'AppVersion="([^"]+)"', package_text)
    if not match:
        raise ValueError("PackageContents.xml is missing AppVersion")
    return match.group(1)


def version_slug(version: str) -> str:
    return version.replace(".", "_")


def validate_bundle() -> str:
    version = package_version()
    errors: list[str] = []

    required_paths = [
        SOURCE_BUNDLE_DIR / "PackageContents.xml",
        SOURCE_BUNDLE_DIR / "README.md",
        SOURCE_BUNDLE_DIR / "Contents" / "LISP" / "cadpoints.lsp",
        SOURCE_BUNDLE_DIR / "Contents" / "Resources" / "help.html",
        SOURCE_BUNDLE_DIR / "Contents" / "Menu" / "cadpoints.mnu",
        SOURCE_BUNDLE_DIR / "Contents" / "Test" / "example_test.dxf",
        SOURCE_BUNDLE_DIR / "Contents" / "Test" / "create_example_test.scr",
        SOURCE_BUNDLE_DIR / "Contents" / "Test" / "cadpoints_smoke_test.lsp",
        SOURCE_BUNDLE_DIR / "Contents" / "Test" / "README_TEST.md",
    ]
    for path in required_paths:
        if not path.exists():
            errors.append(f"Missing required file: {path.relative_to(REPO_ROOT)}")

    if not errors:
        lsp_text = read_text(SOURCE_BUNDLE_DIR / "Contents" / "LISP" / "cadpoints.lsp")
        bundle_readme = read_text(SOURCE_BUNDLE_DIR / "README.md")
        root_readme = read_text(REPO_ROOT / "README.md")
        help_html = read_text(SOURCE_BUNDLE_DIR / "Contents" / "Resources" / "help.html")
        package_json = read_text(REPO_ROOT / "package.json")

        expected_lsp = f'(setq *cadpoints-version* "{version}")'
        if expected_lsp not in lsp_text:
            errors.append(f"cadpoints.lsp version does not match {version}")

        try:
            package_json_version = json.loads(package_json).get("version")
        except json.JSONDecodeError as exc:
            errors.append(f"package.json is invalid JSON: {exc}")
        else:
            if package_json_version != version:
                errors.append(f"package.json version does not match {version}")

        for label, text in [
            ("root README.md", root_readme),
            ("bundle README.md", bundle_readme),
            ("help.html", help_html),
        ]:
            if version not in text:
                errors.append(f"{label} does not mention version {version}")

    if errors:
        raise ValueError("\n".join(errors))

    return version


def build_dist_bundle() -> Path:
    if DIST_BUNDLE_DIR.exists():
        try:
            shutil.rmtree(DIST_BUNDLE_DIR)
        except PermissionError:
            # Fall back to a clean staging tree when the generated dist bundle is
            # open in an editor or file preview and cannot be removed safely.
            staging_root = Path(tempfile.mkdtemp(prefix="CadPoints.bundle_staging_"))
            staging_dir = staging_root / "CadPoints.bundle"
            shutil.copytree(SOURCE_BUNDLE_DIR, staging_dir)
            return staging_dir
    DIST_BUNDLE_DIR.parent.mkdir(exist_ok=True)
    shutil.copytree(SOURCE_BUNDLE_DIR, DIST_BUNDLE_DIR)
    return DIST_BUNDLE_DIR


def run_static_tests() -> None:
    subprocess.run(
        [sys.executable, str(REPO_ROOT / "tests" / "run_static_tests.py")],
        cwd=REPO_ROOT,
        check=True,
    )


def create_zip(version: str) -> Path:
    bundle_dir = build_dist_bundle()
    RELEASES_DIR.mkdir(exist_ok=True)
    zip_path = RELEASES_DIR / f"CadPoints_LT_Plugin_v{version_slug(version)}.zip"

    with zipfile.ZipFile(zip_path, "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(bundle_dir.rglob("*")):
            if path.is_file():
                archive.write(path, Path("CadPoints.bundle") / path.relative_to(bundle_dir))
        if INSTALLER_BAT.exists():
            archive.write(INSTALLER_BAT, INSTALLER_BAT.name)

    with zipfile.ZipFile(zip_path) as archive:
        names = set(archive.namelist())
        if "CadPoints.bundle/PackageContents.xml" not in names:
            raise ValueError("Release ZIP does not contain CadPoints.bundle/PackageContents.xml")
        if INSTALLER_BAT.exists() and INSTALLER_BAT.name not in names:
            raise ValueError(f"Release ZIP does not contain {INSTALLER_BAT.name}")

    return zip_path


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate and package the CadPoints AutoCAD LT bundle.")
    parser.add_argument(
        "--check",
        action="store_true",
        help="Only validate the source bundle and run static tests; do not create dist output or a ZIP.",
    )
    args = parser.parse_args()

    version = validate_bundle()
    run_static_tests()

    if args.check:
        print(f"Release checks OK for CadPoints {version}")
        return 0

    zip_path = create_zip(version)
    print(f"Created {zip_path.relative_to(REPO_ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
