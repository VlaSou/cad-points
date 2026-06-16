from __future__ import annotations

import json
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


def package_version() -> str:
    package_json = json.loads((REPO_ROOT / "package.json").read_text(encoding="utf-8"))
    version = package_json.get("version")
    if not isinstance(version, str):
        raise AssertionError("package.json version is missing")
    return version


def version_slug(version: str) -> str:
    return version.replace(".", "_")


def main() -> int:
    version = package_version()
    exe_path = REPO_ROOT / "releases" / f"CadPoints_LT_Plugin_v{version_slug(version)}.exe"

    if not exe_path.exists():
        print("INSTALLER EXE TEST FAILED")
        print(f"Missing installer EXE: {exe_path.relative_to(REPO_ROOT)}")
        return 1

    header = exe_path.read_bytes()[:2]
    if header != b"MZ":
        print("INSTALLER EXE TEST FAILED")
        print(f"{exe_path.relative_to(REPO_ROOT)} is not a Windows executable")
        return 1

    if exe_path.stat().st_size < 1024:
        print("INSTALLER EXE TEST FAILED")
        print(f"{exe_path.relative_to(REPO_ROOT)} is unexpectedly small")
        return 1

    print("INSTALLER EXE TEST OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
