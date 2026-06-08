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

- [x] Standardize generated/build output directories.
  - Keep source, test assets, release zips, and temporary build output clearly separated.
  - `dist/` and release ZIPs are generated artifacts and ignored by Git.

- [x] Standardize command names, setting names, and default layers in one documented table.
  - Commands: `CPSETTINGS`, `CPEXPORT`, `CPHELP`.
  - Default output layers: `CADPOINTS_POINTS`, `CADPOINTS_POINT_LABELS`, `CADPOINTS_TABLE`, `CADPOINTS_CONTOURS`.
  - `docs/settings.md` is the canonical settings reference, and `help.html` now includes command and output-layer summaries.

## Documentation

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
  - Root README and Czech README now link directly to `releases/CadPoints_LT_Plugin_v0_6_2.zip`.

- [ ] Add optional `.cuix` support for a ready-made ribbon panel.
  - The current install flow works without admin rights, but the user still has to create or load a panel manually.
  - Generate or provide a tested CUIx that exposes `CPEXPORT`, `CPSETTINGS`, and `CPHELP`.
  - Verify the CUIx in AutoCAD LT 2026.1.1 before treating it as release-ready.

- [ ] Add future packaging targets for broader distribution.
  - Chocolatey package for Windows users who prefer package-manager installs.
  - Homebrew formula or cask if a macOS-compatible distribution story ever becomes relevant.
  - A self-contained executable installer is the preferred next distribution target and should become the primary user-facing download.
  - Keep the current release ZIP and `.bat` installer as the interim low-friction path until the executable installer exists.

## Tests And Quality Gates

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
  - Added `tests/test_release_zip.py` and wired it into `tests/run_static_tests.py`.

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

- [x] Add a verification-agent onboarding file.
  - Added `.agents/AGENTS.verification.md` for a local agent that can clone, install, build, and verify CadPoints in AutoCAD LT.

- [x] Expose the `.agents/` folder in root `AGENTS.md`.
  - Root instructions now point to `.agents/` and to `.agents/AGENTS.verification.md` as the canonical agent runbook location.

- [x] Add separate agent runbooks for development and test workflows.
  - Added `.agents/AGENTS.development.md` for implementation and release work.
  - Added `.agents/AGENTS.test.md` for static, release, install, and AutoCAD LT smoke-test validation.
  - Added `.agents/AGENTS.verification.md` for end-to-end local clone/install/AutoCAD verification.

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
