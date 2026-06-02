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
    '(setq *cadpoints-version* "0.6.0")',
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
    "0.6.0",
    "Point naming",
    "example_test.dxf",
    "cadpoints_smoke_test.lsp",
    "DWG writing requires AutoCAD",
    "Troubleshooting",
    "Quick Diagnostics",
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
    "Rychlé řešení problémů",
    "Rychlá diagnostika",
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

package_json_text = package_json.read_text(encoding="utf-8")
try:
    package_json_data = json.loads(package_json_text)
except json.JSONDecodeError as exc:
    errors.append(f"package.json is invalid JSON: {exc}")
else:
    if package_json_data.get("name") != "@vlasou/cad-points":
        errors.append("package.json name is not @vlasou/cad-points")
    if package_json_data.get("version") != "0.6.0":
        errors.append("package.json version is not 0.6.0")
    if "build" not in package_json_data.get("scripts", {}):
        errors.append("package.json is missing the build script")

pkg_text = package.read_text(encoding="utf-8")
if 'AppVersion="0.6.0"' not in pkg_text:
    errors.append("PackageContents.xml AppVersion is not 0.6.0")

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

print("STATIC TESTS OK")
