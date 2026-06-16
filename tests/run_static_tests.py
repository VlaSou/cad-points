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
requirements_doc = repo_root / ".agents" / "requirements.md"
package_json = repo_root / "package.json"
version_script = repo_root / "scripts" / "version.py"
release_wrapper = repo_root / "scripts" / "release.py"
diagnostics_script = repo_root / "scripts" / "diagnostics.py"
release_zip_test = repo_root / "tests" / "test_release_zip.py"
runtime_checklist = repo_root / "docs" / "runtime-test-checklist.md"
agents_base = repo_root / ".agents" / "base.md"
agents_development = repo_root / ".agents" / "development.md"
agents_test = repo_root / ".agents" / "test.md"
agents_verification = repo_root / ".agents" / "verification.md"
agents_autocad = repo_root / ".agents" / "autocad.md"

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
    requirements_doc,
    package_json,
    version_script,
    release_wrapper,
    diagnostics_script,
    release_zip_test,
    runtime_checklist,
    agents_base,
    agents_development,
    agents_test,
    agents_verification,
    agents_autocad,
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

if "fboundp" in text:
    errors.append("cadpoints.lsp must not use fboundp; AutoCAD LT 2026 runtime testing showed it is unavailable")

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
    ".agents/requirements.md",
    "cadpoints_runtime_smoke_test.lsp",
    "expected_output.csv",
    "CPFULLSMOKE",
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
    ".agents/requirements.md",
    "cadpoints_runtime_smoke_test.lsp",
    "expected_output.csv",
    "CPFULLSMOKE",
]:
    if token not in cz_readme_text:
        errors.append(f"Missing token in Czech README: {token}")

requirements_text = requirements_doc.read_text(encoding="utf-8")
for token in [
    "D:\\Autodesk\\AutoCAD LT 2026\\acadlt.exe",
    "Windows PowerShell 5.1",
    "CPFULLSMOKE",
    "expected_output.csv",
    "Do not install, repair, upgrade, or reinstall AutoCAD itself unless explicitly requested.",
]:
    if token not in requirements_text:
        errors.append(f"Missing token in requirements doc: {token}")

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

agents_base_text = agents_base.read_text(encoding="utf-8")
for token in [
    "baseline instructions for AI coding agents",
    "Priority",
    "Scope discipline",
    "Change protocol",
    "Git safety",
    "Do not claim that validation passed unless it actually ran successfully",
]:
    if token not in agents_base_text:
        errors.append(f"Missing token in base agent runbook: {token}")

for path in [agents_development, agents_test, agents_verification]:
    agent_text = path.read_text(encoding="utf-8")
    if "base.md" not in agent_text:
        errors.append(f"Missing base.md reference in {path.relative_to(repo_root)}")

agents_autocad_text = agents_autocad.read_text(encoding="utf-8")
for token in [
    "Official AppAutoloader Rules",
    "PackageContents.xml",
    "RuntimeRequirements",
    "ApplicationPlugins",
    "CUI",
    "CUILOAD",
]:
    if token not in agents_autocad_text:
        errors.append(f"Missing token in AutoCAD agent notes: {token}")

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

for filename in ["example_test.dxf", "create_example_test.scr", "cadpoints_smoke_test.lsp", "cadpoints_runtime_smoke_test.lsp", "expected_output.csv", "README_TEST.md"]:
    if not (test_dir / filename).exists():
        errors.append(f"Missing test file: {filename}")

runtime_smoke_text = (test_dir / "cadpoints_runtime_smoke_test.lsp").read_text(encoding="utf-8")
for token in [
    "CPFULLSMOKE",
    "cp-test:create-example-input",
    "cp-test:command-defined-p",
    "cp-test:csv-lines-match-p",
    "expected_output.csv",
    "CADPOINTS_POINTS",
    "CADPOINTS_POINT_LABELS",
    "CADPOINTS_TABLE",
    "CP_POINTS_A,CP_POINTS_B",
]:
    if token not in runtime_smoke_text:
        errors.append(f"Missing token in runtime smoke test: {token}")

expected_csv_text = (test_dir / "expected_output.csv").read_text(encoding="utf-8")
for token in [
    "Bod;Hladina;Objekt;Vrchol;Y S-JTSK;X S-JTSK;Z",
    "A001;CP_POINTS_A;LINE;1;1000;2000;10",
    "B003;CP_POINTS_B;LWPOLYLINE;3;4000;2000;30",
]:
    if token not in expected_csv_text:
        errors.append(f"Missing token in expected CSV: {token}")

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
