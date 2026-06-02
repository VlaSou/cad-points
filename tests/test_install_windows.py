from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
INSTALLER = REPO_ROOT / "scripts" / "install_windows.bat"
SOURCE_BUNDLE = REPO_ROOT / "src" / "CadPoints.bundle"


def run_install(destination_root: Path, cwd: Path) -> subprocess.CompletedProcess[str]:
    command = [
        "cmd.exe",
        "/c",
        str(INSTALLER),
        str(SOURCE_BUNDLE),
        str(destination_root),
    ]
    return subprocess.run(
        command,
        cwd=cwd,
        text=True,
        capture_output=True,
        check=False,
    )


def assert_bundle_contents(bundle_dir: Path) -> None:
    required_paths = [
        bundle_dir / "PackageContents.xml",
        bundle_dir / "README.md",
        bundle_dir / "Contents" / "LISP" / "cadpoints.lsp",
        bundle_dir / "Contents" / "Menu" / "cadpoints.mnu",
        bundle_dir / "Contents" / "Resources" / "help.html",
        bundle_dir / "Contents" / "Test" / "example_test.dxf",
    ]
    for path in required_paths:
        if not path.exists():
            raise AssertionError(f"Missing installed file: {path}")


def main() -> int:
    if not INSTALLER.exists():
        print(f"Missing installer: {INSTALLER.relative_to(REPO_ROOT)}")
        return 1
    if not SOURCE_BUNDLE.exists():
        print(f"Missing source bundle: {SOURCE_BUNDLE.relative_to(REPO_ROOT)}")
        return 1

    with tempfile.TemporaryDirectory(prefix="cadpoints-install-test-") as temp_dir:
        temp_root = Path(temp_dir)
        destination_root = temp_root / "ApplicationPlugins"
        destination_bundle = destination_root / "CadPoints.bundle"

        destination_root.mkdir(parents=True, exist_ok=True)
        destination_bundle.mkdir(parents=True, exist_ok=True)
        sentinel = destination_bundle / "sentinel.txt"
        sentinel.write_text("old bundle", encoding="utf-8")

        result = run_install(destination_root=destination_root, cwd=REPO_ROOT)
        if result.returncode != 0:
            print("INSTALLER TEST FAILED")
            print("STDOUT:")
            print(result.stdout)
            print("STDERR:")
            print(result.stderr)
            return result.returncode

        if sentinel.exists():
            print("INSTALLER TEST FAILED")
            print("Sentinel file still exists, old bundle was not replaced.")
            return 1

        if not destination_bundle.exists():
            print("INSTALLER TEST FAILED")
            print("Destination bundle was not created.")
            return 1

        assert_bundle_contents(destination_bundle)

        source_package = (SOURCE_BUNDLE / "PackageContents.xml").read_text(encoding="utf-8")
        installed_package = (destination_bundle / "PackageContents.xml").read_text(encoding="utf-8")
        if source_package != installed_package:
            print("INSTALLER TEST FAILED")
            print("Installed PackageContents.xml does not match source.")
            return 1

        print("INSTALLER TEST OK")
        return 0


if __name__ == "__main__":
    raise SystemExit(main())
