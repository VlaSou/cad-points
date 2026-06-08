import subprocess
import sys
import json
from pathlib import Path

repo_root = Path(__file__).resolve().parents[1]
root = repo_root / "src" / "CadPoints.bundle"
lsp = root / "Contents" / "LISP" / "cadpoints.lsp"
readme = root / "README.md"
package = root / "PackageContents.xml"
test_dir = root / "Contents" / "Test"
installer = repo_root / "scripts" / "install_windows.bat"
cz_readme = repo_root / "README.cs-CZ.md"
installer_test = repo_root / "tests" / "test_install_windows.py"
docs_dev = repo_root / "docs" / "development.md"
docs_settings = repo_root / "docs" / "settings.md"
package_json = repo_root / "package.json"
version_script = repo_root / "scripts" / "version.py"
release_wrapper = repo_root / "scripts" / "release.py"
diagnostics_script = repo_root / "scripts" / "diagnostics.py"
release_zip_test = repo_root / "tests" / "test_release_zip.py"
runtime_checklist = repo_root / "docs" / "runtime-test-checklist.md"

errors = []
for required_path in [
    root,
    lsp,
    readme,
    package,
    test_dir,
    installer,
    cz_readme,
    installer_test,
    docs_dev,
    docs_settings,
    package_json,
    version_script,
    release_wrapper,
    diagnostics_script,
    release_zip_test,
    runtime_checklist,
]:
    if not required_path.exists():
        errors.append(f"Missing required path: {required_path.relative_to(repo_root)}")

if errors:
    print("STATIC TESTS FAILED")
    for error in errors:
        print("-", error)
    raise SystemExit(1)

text = lsp.read_text(encoding="utf-8")

# Parenthesis balance ignoring comments and strings.
def stripped_lisp(source: str) -> str:
    output = []
    for line in source.splitlines():
        in_string = False
        result = []
        for char in line:
            if char == '"':
                in_string = not in_string
                result.append(' ')
            elif not in_string and char == ';':
                break
            else:
                result.append(' ' if in_string else char)
        output.append(''.join(result))
    return '\n'.join(output)

plain = stripped_lisp(text)
if plain.count('(') != plain.count(')'):
    errors.append(f"Unbalanced parentheses: {plain.count('(')} != {plain.count(')')}")

required_tokens = [
    '(cons "DRAWING_SCALE"',
    '(cons "POINT_NAME_PATTERN"',
    '(cons "DRAW_POINTS"',
    '(cons "POINT_LAYER"',
    '(cons "LABEL_PAPER_HEIGHT"',
    'POINT_NAME:Bod',
    'CADPOINTS_POINTS',
    'CADPOINTS_POINT_LABELS',
    '(defun cp:next-point-name',
    '(defun cp:add-point',
]
for token in required_tokens:
    if token not in text:
        errors.append(f"Missing token in LISP: {token}")

readme_text = readme.read_text(encoding="utf-8")
for token in [
    "Point naming",
    "example_test.dxf",
    "cadpoints_smoke_test.lsp",
    "DWG writing requires AutoCAD",
    "Troubleshooting",
    "Quick Diagnostics",
    "scripts/diagnostics.py",
    "cadpoints-diagnostics.txt",
    "docs/development.md",
    "docs/settings.md",
]:
    if token not in readme_text:
        errors.append(f"Missing token in README: {token}")

cz_readme_text = cz_readme.read_text(encoding="utf-8")
for token in [
    "scripts\\install_windows.bat",
    "AutoCAD LT 2026.1.1",
    "%APPDATA%\\Autodesk\\ApplicationPlugins",
    "Řešení problémů",
    "Rychlá diagnostika",
    "scripts/diagnostics.py",
    "cadpoints-diagnostics.txt",
    "docs/development.md",
    "docs/settings.md",
]:
    if token not in cz_readme_text:
        errors.append(f"Missing token in Czech README: {token}")

docs_dev_text = docs_dev.read_text(encoding="utf-8")
for token in [
    "Repository Layout",
    "Build And Release",
    "Testing Workflow",
    "AutoCAD LT Limitations",
    "Quick Diagnostics",
]:
    if token not in docs_dev_text:
        errors.append(f"Missing token in development docs: {token}")

docs_settings_text = docs_settings.read_text(encoding="utf-8")
for token in [
    "CPSETTINGS",
    "CPEXPORT",
    "CPHELP",
    "CADPOINTS_POINTS",
    "CADPOINTS_POINT_LABELS",
    "CADPOINTS_TABLE",
    "CADPOINTS_CONTOURS",
]:
    if token not in docs_settings_text:
        errors.append(f"Missing token in settings docs: {token}")

runtime_checklist_text = runtime_checklist.read_text(encoding="utf-8")
for token in [
    "AutoCAD LT Runtime Test Checklist",
    "Do not mark runtime behavior as verified",
    "CPSETTINGS",
    "CPEXPORT",
    "CPHELP",
    "CADPOINTS_POINTS",
    "CADPOINTS_POINT_LABELS",
]:
    if token not in runtime_checklist_text:
        errors.append(f"Missing token in runtime checklist: {token}")

package_json_text = package_json.read_text(encoding="utf-8")
try:
    package_json_data = json.loads(package_json_text)
except json.JSONDecodeError as exc:
    errors.append(f"package.json is invalid JSON: {exc}")
else:
    version = package_json_data.get("version")
    if package_json_data.get("name") != "@vlasou/cad-points":
        errors.append("package.json name is not @vlasou/cad-points")
    if not isinstance(version, str) or not version.count(".") == 2:
        errors.append("package.json version is missing or invalid")
    if package_json_data.get("packageManager") != "pnpm@9.15.4":
        errors.append("package.json packageManager is not pnpm@9.15.4")
    scripts = package_json_data.get("scripts", {})
    expected_scripts = {
        "check": "py -3 tests/run_static_tests.py",
        "test": "pnpm check",
        "diagnostics": "py -3 scripts/diagnostics.py",
        "version:patch": "py -3 scripts/version.py patch",
        "version:minor": "py -3 scripts/version.py minor",
        "version:major": "py -3 scripts/version.py major",
        "package:dist": "py -3 scripts/release.py --package-only",
        "build:autoinstaller": "py -3 scripts/release.py",
        "build": "pnpm build:autoinstaller",
        "release:check": "py -3 scripts/release.py --check",
        "release": "pnpm build:autoinstaller",
    }
    for script_name, expected_value in expected_scripts.items():
        actual_value = scripts.get(script_name)
        if actual_value != expected_value:
            errors.append(
                f"package.json script {script_name} is {actual_value!r}, expected {expected_value!r}"
            )

    help_html_text = (root / "Contents" / "Resources" / "help.html").read_text(encoding="utf-8")
    versioned_bodies = {
        "bundle README": readme_text,
        "Czech README": cz_readme_text,
        "help.html": help_html_text,
        "PackageContents.xml": package.read_text(encoding="utf-8"),
        "cadpoints.lsp": text,
    }
    for label, body in versioned_bodies.items():
        if version not in body:
            errors.append(f"Missing version {version} in {label}")

version_wrapper_text = version_script.read_text(encoding="utf-8")
for token in ["bump_semver", "replace_first", "Release ZIP name will use"]:
    if token not in version_wrapper_text:
        errors.append(f"Missing token in version wrapper: {token}")

wrapper_text = release_wrapper.read_text(encoding="utf-8")
for token in ["package_version", "validate_bundle", "create_zip", "--package-only"]:
    if token not in wrapper_text:
        errors.append(f"Missing token in release wrapper: {token}")

for filename in ["example_test.dxf", "create_example_test.scr", "cadpoints_smoke_test.lsp", "README_TEST.md"]:
    if not (test_dir / filename).exists():
        errors.append(f"Missing test file: {filename}")

# Verify the DXF has the expected source layers.
dxf = (test_dir / "example_test.dxf").read_text(encoding="utf-8")
for layer in ["CP_POINTS_A", "CP_POINTS_B"]:
    if layer not in dxf:
        errors.append(f"Missing DXF layer: {layer}")

if errors:
    print("STATIC TESTS FAILED")
    for error in errors:
        print("-", error)
    raise SystemExit(1)

installer_test_result = subprocess.run(
    [sys.executable, str(installer_test)],
    cwd=repo_root,
    text=True,
    capture_output=True,
    check=False,
)
if installer_test_result.returncode != 0:
    print("STATIC TESTS FAILED")
    print(installer_test_result.stdout, end="")
    print(installer_test_result.stderr, end="")
    raise SystemExit(installer_test_result.returncode)

release_zip_test_result = subprocess.run(
    [sys.executable, str(release_zip_test)],
    cwd=repo_root,
    text=True,
    capture_output=True,
    check=False,
)
if release_zip_test_result.returncode != 0:
    print("STATIC TESTS FAILED")
    print(release_zip_test_result.stdout, end="")
    print(release_zip_test_result.stderr, end="")
    raise SystemExit(release_zip_test_result.returncode)

print("STATIC TESTS OK")
