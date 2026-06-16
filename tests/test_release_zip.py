from __future__ import annotations

import json
import sys
import zipfile
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
PACKAGE_JSON = REPO_ROOT / "package.json"
RELEASES_DIR = REPO_ROOT / "releases"


def version_slug(version: str) -> str:
    return version.replace(".", "_")


def main() -> int:
    package = json.loads(PACKAGE_JSON.read_text(encoding="utf-8"))
    version = package.get("version")
    if not isinstance(version, str) or version.count(".") != 2:
        print("RELEASE ZIP TEST FAILED")
        print("- package.json version is missing or invalid")
        return 1

    zip_path = RELEASES_DIR / f"CadPoints_LT_Plugin_v{version_slug(version)}.zip"
    errors: list[str] = []

    if not zip_path.exists():
        errors.append(f"Missing release ZIP: {zip_path.relative_to(REPO_ROOT)}")
    else:
        with zipfile.ZipFile(zip_path) as archive:
            names = set(archive.namelist())
            required_entries = [
                "CadPoints.bundle/PackageContents.xml",
                "CadPoints.bundle/README.md",
                "CadPoints.bundle/Contents/LISP/cadpoints.lsp",
                "CadPoints.bundle/Contents/Resources/help.html",
                "CadPoints.bundle/Contents/Menu/cadpoints.mnu",
                "CadPoints.bundle/Contents/Test/example_test.dxf",
                "CadPoints.bundle/Contents/Test/create_example_test.scr",
                "CadPoints.bundle/Contents/Test/cadpoints_smoke_test.lsp",
                "CadPoints.bundle/Contents/Test/cadpoints_runtime_smoke.scr",
                "CadPoints.bundle/Contents/Test/cadpoints_runtime_smoke_test.lsp",
                "CadPoints.bundle/Contents/Test/expected_output.csv",
                "CadPoints.bundle/Contents/Test/README_TEST.md",
                "install_windows.bat",
            ]
            for entry in required_entries:
                if entry not in names:
                    errors.append(f"Missing ZIP entry: {entry}")

            for name in names:
                if name.startswith("dist/") or name.startswith("src/"):
                    errors.append(f"ZIP has unexpected parent directory: {name}")
                if "CadPoints.bundle/CadPoints.bundle/" in name:
                    errors.append(f"ZIP has nested bundle directory: {name}")

            package_contents = archive.read("CadPoints.bundle/PackageContents.xml").decode("utf-8")
            if f'AppVersion="{version}"' not in package_contents:
                errors.append(f"PackageContents.xml inside ZIP does not match version {version}")

    if errors:
        print("RELEASE ZIP TEST FAILED")
        for error in errors:
            print("-", error)
        return 1

    print("RELEASE ZIP TEST OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
