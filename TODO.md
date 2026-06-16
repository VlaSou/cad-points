# TODO

CadPoints is currently a compact AutoCAD LT bundle project with editable bundle source under `src/CadPoints.bundle`, generated build output under `dist/CadPoints.bundle`, root and bundle README files, AutoLISP source, resources, menu helpers, and a Python static test script. The next useful work is improving documentation, tests, and release consistency.

## Standardization

- [x] Fix GitHub push authentication for this workstation.
  - Push works when using `GIT_SSH_COMMAND` with `C:/Users/vsous/.ssh/id_ed25519_vlasou`.
  - Keep using that key for SSH pushes unless the default SSH config is updated.

- [x] Add a project rule that `TODO.md` must be updated after each task.
  - The rule is now part of `AGENTS.md` development and communication guidance.

- [x] Decide the canonical bundle location and update the repository to match it.
  - Canonical editable source path: `src/CadPoints.bundle`.
  - Generated build output path: `dist/CadPoints.bundle`.
  - Release ZIPs contain `CadPoints.bundle/` at the archive root.

- [x] Fix `tests/run_static_tests.py` path resolution.
  - The script now resolves the canonical source bundle path from the repository root: `src/CadPoints.bundle`.

- [x] Add a single source of truth for the project version.
  - `package.json` is the canonical version source.
  - `pnpm version:patch|minor|major` updates `package.json`, `PackageContents.xml`, `cadpoints.lsp`, the README files, and `help.html` together.
  - The release build and static checks verify that the versioned files stay in sync.

- [x] Add a repeatable release build script.
  - Validate bundle structure.
  - Run static tests.
  - Create `releases/CadPoints_LT_Plugin_vX_Y_Z.zip`.
  - Ensure the ZIP root contains `CadPoints.bundle/` directly, without an extra parent folder.
  - The build now falls back to a temporary staging copy if `dist/CadPoints.bundle` is locked by an editor.
  - `dist/` is the generated package payload / staging output for npm/GitHub Packages, while `releases/` is the autoinstaller artifact output.
  - Use the SemVer bump script before release when the version needs to change.
  - Already committed release ZIPs are immutable; create a new SemVer ZIP instead of editing an older published artifact.

- [x] Standardize generated/build output directories.
  - Keep source, test assets, release zips, and temporary build output clearly separated.
  - `dist/` and release ZIPs are generated artifacts and ignored by Git.

- [x] Standardize command names, setting names, and default layers in one documented table.
  - Commands: `CPSETTINGS`, `CPEXPORT`, `CPHELP`.
  - Default output layers: `CADPOINTS_POINTS`, `CADPOINTS_POINT_LABELS`, `CADPOINTS_TABLE`, `CADPOINTS_CONTOURS`.
  - `docs/settings.md` is the canonical settings reference, and `help.html` now includes command and output-layer summaries.

## Documentation

- [x] Add local runtime test requirements document.
  - Moved the document to `.agents/requirements.md` so agent-facing workstation requirements stay with the other agent runbooks.
  - Documents local workstation capabilities that improve automated AutoCAD LT testing.
  - Covers PATH/alias setup, Windows PowerShell 5.1 COM usage, license dialogs, trust paths, runtime smoke assets, and what is not required.
  - Python is confirmed installed on this workstation; use `py -3` for repository scripts.

- [x] Add Czech user-facing README.
  - Added `README.cs-CZ.md` as a Czech localized version of the current user documentation.
  - Reworked the install flow for non-technical Windows users.

- [x] Add a simple Windows installer script.
  - Added `scripts/install_windows.bat`.
  - The script installs the bundle into `%APPDATA%\Autodesk\ApplicationPlugins` without admin rights.
  - It auto-finds the bundle from `dist/`, `src/`, or the current working directory.

- [x] Split documentation by audience.
  - Keep root `README.md` as the user-facing quick start.
  - Add `docs/development.md` for repository layout, testing, release process, and AutoCAD LT limitations.
  - Add `docs/settings.md` for all environment-backed settings and defaults.
  - Completed in root README, Czech README, bundle README, and new docs files.

- [x] Add a troubleshooting section.
  - Bundle does not autoload.
  - `CPEXPORT` exports zero points.
  - Source layers do not match configured layers.
  - CSV path or write permission fails.
  - Curved geometry sampling fails because an AutoCAD LT curve function is unavailable.
  - Table or labels appear at unexpected scale because drawing/table scale is wrong.
  - Completed in root README, Czech README, bundle README, docs, and `help.html`.

- [x] Document the test workflow end to end.
  - Static test command from repository root.
  - AutoCAD LT smoke test commands.
  - Expected generated CSV, point layers, labels, table, and point naming behavior.
  - Explicitly state that AutoCAD runtime testing is required for true validation.
  - Completed in root README, Czech README, bundle README, and docs.

- [x] Add a shareable diagnostics report.
  - `pnpm diagnostics` and `py -3 scripts/diagnostics.py` now print a local report that can be pasted back.
  - The report includes version checks, file presence checks, tracked release ZIPs, and a copy/paste AutoCAD checklist.
  - The README files now tell users exactly what to send when they ask for help.

- [x] Expand `Contents/Resources/help.html`.
  - Added install path, command list, default units, source layer setup, naming rules, CSV/table columns, S-JTSK convention, output layers, troubleshooting, and contour limitation.

- [x] Document release verification.
  - Confirm `PackageContents.xml` version.
  - Confirm `cadpoints.lsp` version.
  - Confirm root and bundle README version.
  - Confirm ZIP structure.
  - Confirm smoke test status.
  - Confirm `dist/CadPoints.bundle` is not open in another app before running the build.
  - The generated autoinstaller ZIPs are tracked in `releases/` for easy download from the repository.

- [x] Add a README download shortcut to the latest release ZIP.
  - Root README and Czech README now link directly to `releases/CadPoints_LT_Plugin_v0_6_5.exe` and `releases/CadPoints_LT_Plugin_v0_6_5.zip`.

- [ ] Add optional `.cuix` support for a ready-made ribbon panel.
  - The current install flow works without admin rights, but the user still has to create or load a panel manually.
  - Generate or provide a tested CUIx that exposes `CPEXPORT`, `CPSETTINGS`, and `CPHELP`.
  - Verify the CUIx in AutoCAD LT 2026.1.1 before treating it as release-ready.

- [ ] Add future packaging targets for broader distribution.
  - Chocolatey package for Windows users who prefer package-manager installs.
  - Homebrew formula or cask if a macOS-compatible distribution story ever becomes relevant.
  - A self-contained executable installer is the preferred next distribution target and should become the primary user-facing download.
  - Keep `install_windows.bat` at the release ZIP root next to `CadPoints.bundle`, not inside the bundle.
  - Treat MSI as a later enterprise/deployment target, not the immediate default.
  - Keep the current release ZIP and `.bat` installer as the interim low-friction path until the executable installer exists.

- [x] Implement a self-contained Windows `.exe` installer.
  - Use the local .NET Framework C# compiler for the first implementation to avoid adding WiX/Inno/NSIS as a project dependency.
  - Package the generated `dist/CadPoints.bundle` payload together with `install_windows.bat`.
  - The EXE should auto-run `install_windows.bat` after extraction and install into `%APPDATA%\Autodesk\ApplicationPlugins`.
  - Add `pnpm build:installer-exe` and release/static checks for the generated `.exe`.
  - Bump SemVer before publishing the first EXE artifact because version 0.6.3 has already been committed.
  - Implemented `scripts/build_installer_exe.ps1`, `tests/test_installer_exe.py`, and `releases/CadPoints_LT_Plugin_v0_6_4.exe`.
  - Verified `py -3 tests/test_installer_exe.py` checks the generated EXE header and artifact size.
  - Rejected IExpress after local testing produced `LoadString() Error. Could not load string resource.`; the current builder compiles a small .NET Framework C# installer instead.
  - 2026-06-16 quiet EXE verification passed: `releases\CadPoints_LT_Plugin_v0_6_4.exe /Q` installed CadPoints 0.6.4 into `%APPDATA%\Autodesk\ApplicationPlugins`.

- [x] Verify the generated `.exe` installer end-to-end from Explorer or quiet command-line mode.
  - Confirmed quiet mode installs `CadPoints.bundle` into `%APPDATA%\Autodesk\ApplicationPlugins`.
  - Confirm AutoCAD LT loads the installed bundle without the unsigned test-helper prompt when using `cadpoints_runtime_smoke.scr`.
  - Keep MSI as a later enterprise packaging target only if the EXE installer proves insufficient.

- [x] Fix EXE installer feedback and AutoCAD startup autoload.
  - Add a visible success/failure dialog for non-quiet EXE runs.
  - Verify the installed bundle after copy and show the installed path/version.
  - Add `LoadReasons="LoadOnAutoCADStartup"` to `PackageContents.xml` so `CPHELP`, `CPSETTINGS`, and `CPEXPORT` are available after AutoCAD restart.
  - Implemented in 0.6.5. Non-quiet EXE shows a success/failure MessageBox and includes batch installer output in failure details.
  - Static tests now require `LoadReasons="LoadOnAutoCADStartup"` in `PackageContents.xml`.

## Tests And Quality Gates

- [x] Complete AutoCAD LT runtime verification with the installed local AutoCAD LT.
  - AutoCAD itself must not be installed, repaired, or upgraded by agents unless explicitly requested.
  - User allowed agents to make changes under `D:\Autodesk\` at their discretion for CadPoints verification; keep changes targeted to the existing clean trial install.
  - Trial timing note: clean AutoCAD LT trial had 9 days remaining on 2026-06-08.
  - Use only the already installed executable: `D:\Autodesk\AutoCAD LT 2026\acadlt.exe`.
  - It is acceptable to install/reinstall only `CadPoints.bundle` into `%APPDATA%\Autodesk\ApplicationPlugins`.
  - Close stale `acadlt.exe` instances before each automated runtime attempt so windows do not accumulate.
  - AutoCAD LT may show a license / unregistered-version dialog during automated `/b` script testing; agents may close that dialog and stale AutoCAD test instances.
  - 2026-06-16 result: installed 0.6.3 bundle passed `CPFULLSMOKE` in AutoCAD LT after closing the license/unregistered-version dialog.
  - Runtime output: 5 records, 5 point entities, 5 labels, 58 table entities, generated CSV matched `expected_output.csv`.
  - Recorded final result in `docs/runtime-test-checklist.md`.

- [x] Run local non-AutoCAD verification for version 0.6.2.
  - Date: 2026-06-08.
  - `py -3 tests/run_static_tests.py` passed.
  - `py -3 scripts/release.py --check` passed.
  - `py -3 scripts/diagnostics.py` reported consistent version metadata and no missing required paths.
  - `py -3 scripts/release.py --package-only` rebuilt `dist/CadPoints.bundle`.
  - `py -3 scripts/release.py` rebuilt `releases/CadPoints_LT_Plugin_v0_6_2.zip`.
  - `py -3 tests/test_install_windows.py` passed.
  - AutoCAD LT runtime smoke testing was not run because no `acadlt.exe` or `acad.exe` installation was found on this workstation.

- [x] Make static tests runnable from a clean checkout with one command.
  - Prefer `python tests/run_static_tests.py` unless the project later adopts a package manager.
  - If JavaScript tooling is added, prefer `pnpm` for dependency management.
  - `package.json` now exposes pnpm-first scripts for check/package/release.
  - `pnpm package:dist` prepares the npm/GitHub Packages payload in `dist/`.
  - `pnpm build:autoinstaller` and `pnpm release` create the tracked autoinstaller ZIPs in `releases/`.
  - `scripts/version.py` and `scripts/release.py` now provide the pnpm release/version entrypoints around the Python workflow.

- [x] Extend static tests to validate documentation coverage.
  - Installation instructions.
  - Manual CUI/ribbon setup.
  - Drawing units and scale behavior.
  - S-JTSK coordinate convention.
  - Contour limitation.
  - Test fixture instructions.
  - Windows installer script coverage.
  - Added an integration test for `scripts/install_windows.bat`.
  - Static checks now also cover the diagnostics script and the new troubleshooting/reporting text.
  - Static checks now require `docs/runtime-test-checklist.md` and verify its key runtime-test tokens.

- [x] Add release-zip validation tests.
  - ZIP exists for the requested version.
  - ZIP contains `CadPoints.bundle/PackageContents.xml`.
  - ZIP contains LISP, resources, menu, test fixtures, and bundle README.
  - ZIP does not contain a nested extra parent directory.
  - Added `tests/test_release_zip.py`.
  - `scripts/release.py --check` runs the release ZIP test against the existing ZIP.
  - `scripts/release.py` runs the release ZIP test after rebuilding the ZIP.

- [ ] Add static checks for AutoLISP command and setting coverage.
  - Required commands are defined.
  - Required settings are present in `cp:settings-list`.
  - Required default layers are present.
  - Parentheses remain balanced while ignoring comments and strings.

- [x] Track runtime test results in a small checklist file.
  - Suggested file: `docs/runtime-test-checklist.md`.
  - Do not mark runtime behavior as verified unless it was tested in AutoCAD LT.
  - Added `docs/runtime-test-checklist.md`.
  - Recorded the 2026-06-08 workstation result: non-AutoCAD checks passed, but no AutoCAD LT executable was available for runtime testing.

- [x] Add deterministic runtime smoke-test fixture and expected output.
  - Added `Contents/Test/expected_output.csv`.
  - Extended `cadpoints_runtime_smoke_test.lsp` so `CPFULLSMOKE` creates a stable input drawing in the current AutoCAD session.
  - The runtime smoke test now compares generated CSV output with `expected_output.csv` without depending on AutoCAD `ssget` selection order.
  - Added `Contents/Test/cadpoints_runtime_smoke.scr`; it adds `CadPoints.bundle\...` to `TRUSTEDPATHS` before loading the runtime smoke LISP to avoid AutoCAD's unsigned executable-file prompt.
  - 2026-06-16 verification confirmed the TRUSTEDPATHS helper loads `cadpoints_runtime_smoke_test.lsp` without blocking the runtime smoke test.
  - Static and release ZIP checks now require the runtime smoke test and expected CSV fixture.
  - This test avoids relying on opening `example_test.dxf` during automated script execution, because AutoCAD LT `/b` testing showed `OPEN` can block on UI/prompt state.
  - Root README, Czech README, bundle README, and docs now document `CPFULLSMOKE`, `expected_output.csv`, and `.agents/requirements.md`.
  - 2026-06-16 AutoCAD LT runtime testing showed `fboundp` is unavailable; CadPoints runtime code and smoke checks no longer use it.

- [x] Add a verification-agent onboarding file.
  - Added `.agents/verification.md` for a local agent that can clone, install, build, and verify CadPoints in AutoCAD LT.

- [x] Expose the `.agents/` folder in root `AGENTS.md`.
  - Root instructions now point to `.agents/` and to `.agents/verification.md` as the canonical agent runbook location.

- [x] Add separate agent runbooks for development and test workflows.
  - Added `.agents/development.md` for implementation and release work.
  - Added `.agents/test.md` for static, release, install, and AutoCAD LT smoke-test validation.
  - Added `.agents/verification.md` for end-to-end local clone/install/AutoCAD verification.

- [x] Add and integrate baseline agent instructions.
  - Added `.agents/base.md` as the baseline, project-agnostic AI coding-agent rule set.
  - Root `AGENTS.md` now lists the baseline runbook and explains how CadPoints project rules extend it.
  - Development, test, and verification runbooks now link back to `base.md`.
  - Static tests now require the baseline runbook and validate key safety tokens.

- [x] Standardize `.agents/` runbook file names.
  - Current canonical names are `.agents/base.md`, `.agents/development.md`, `.agents/test.md`, `.agents/verification.md`, and `.agents/autocad.md`.
  - Updated root `AGENTS.md`, runbook cross-links, static tests, and TODO references to the lowercase names.

- [x] Record AutoCAD LT installation and AppAutoloader findings for agents.
  - Added `.agents/autocad.md`.
  - Recorded that `.bundle` plug-ins should install to shared Autodesk `ApplicationPlugins` folders, not year-specific AutoCAD LT program folders.
  - Recorded local AutoCAD LT 2026 detection at `D:\Autodesk\AutoCAD LT 2026\acadlt.exe`.
  - Recorded CUI/CUILOAD constraints for ribbon/panel automation.
  - Added web-researched Autodesk Help, Autodesk Developer Blog, and supporting community references for AppAutoloader, `PackageContents.xml`, `RuntimeRequirements`, CUIx, `CUI`, and `CUILOAD`.

## AutoLISP Maintainability

- [ ] Group `cadpoints.lsp` into clearer sections with comment headers.
  - Configuration and environment helpers.
  - Naming helpers.
  - Entity creation helpers.
  - Geometry collection.
  - CSV/table output.
  - Contour generation.
  - AutoCAD command entrypoints.

- [ ] Add graceful messages for unsupported or failed curve sampling.
  - Include entity type and handle when available.
  - Avoid silently skipping entities where practical.

- [ ] Consider isolating user-facing Czech command prompts from internal setting IDs.
  - This makes future translation or prompt edits safer without changing setting names.

- [ ] Review contour generation wording and behavior together.
  - Keep documentation clear that contours are approximate segment interpolation, not a TIN/surface model.

## Suggested Order

1. Add version/release validation around one explicit version source.
2. Split developer documentation from user documentation.
3. Expand runtime test documentation and execute it in AutoCAD LT.
4. Extend static tests for documentation coverage.
5. Improve AutoLISP maintainability and runtime error messages.
