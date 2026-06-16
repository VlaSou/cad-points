# executable.md

Scope: CadPoints self-contained Windows `.exe` installer findings, build workflow, and verification notes.

Use this file when changing `scripts/build_installer_exe.ps1`, `tests/test_installer_exe.py`, or release `.exe` artifacts.

## Current Direction

CadPoints keeps the ZIP installer as a release artifact, but the preferred user-facing Windows download is now:

```text
releases/CadPoints_LT_Plugin_vX_Y_Z.exe
```

The `.exe` installer must remain lightweight and user-profile based:

```text
%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle
```

Do not require admin rights for the default install path.

## Implemented Builder

Builder script:

```text
scripts/build_installer_exe.ps1
```

The script:

1. reads the version from `dist/CadPoints.bundle/PackageContents.xml`,
2. copies `dist/CadPoints.bundle` and `scripts/install_windows.bat` into a temporary payload folder,
3. compresses that payload into `CadPoints_payload.zip`,
4. generates a small C# installer source file,
5. embeds `CadPoints_payload.zip` as a managed resource,
6. compiles the installer with local .NET Framework `csc.exe`,
7. writes:

```text
releases/CadPoints_LT_Plugin_vX_Y_Z.exe
```

The generated EXE extracts the embedded payload to `%TEMP%`, runs `install_windows.bat`, then cleans up the temporary folder.

Supported quiet argument:

```text
/Q
```

## Compiler Dependency

The current builder depends on .NET Framework C# compiler:

```text
%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe
%WINDIR%\Microsoft.NET\Framework\v4.0.30319\csc.exe
```

This is intentionally a Windows built-in/runtime dependency rather than adding WiX, Inno Setup, NSIS, or a .NET SDK requirement.

The local workstation has .NET runtimes installed but no .NET SDK. Do not rely on `dotnet build` unless the SDK is explicitly installed later.

## Rejected Approaches

### IExpress

IExpress was tested and rejected.

Observed failure:

```text
LoadString() Error. Could not load string resource.
```

Other problems observed during IExpress attempts:

- stale `~CadPoints_LT_Plugin_vX_Y_Z.*` files in `releases/`,
- CAB/TMP files left behind,
- a generated EXE that did not install the expected CadPoints version,
- poor diagnostics when payload generation failed.

Do not switch back to IExpress unless there is a new, tested reason.

### PowerShell Add-Type OutputAssembly

PowerShell `Add-Type -OutputAssembly` was tested for a temporary EXE and produced a broken executable on this workstation.

Observed failure:

```text
cadpoints-compile-test.exe - Chyba aplikace
Nastala výjimka neznámá softwarová výjimka (0xe0434352)
```

Use `csc.exe` directly instead.

## Build Commands

Recommended release build sequence:

```text
py -3 scripts/version.py patch
py -3 scripts/release.py --package-only
py -3 scripts/release.py
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_installer_exe.ps1
py -3 tests/run_static_tests.py
py -3 tests/test_release_zip.py
py -3 tests/test_installer_exe.py
```

pnpm entrypoints:

```text
pnpm package:dist
pnpm build:autoinstaller
pnpm build:installer-exe
pnpm installer-exe:check
```

## Verification

Current EXE test:

```text
tests/test_installer_exe.py
```

It verifies:

- current-version EXE exists in `releases/`,
- EXE starts with the Windows `MZ` header,
- EXE size is plausible.

Manual/quiet install verification used on 2026-06-16:

```text
releases\CadPoints_LT_Plugin_v0_6_4.exe /Q
```

Result:

- command exited with code `0`,
- installed bundle path existed,
- installed `cadpoints.lsp` contained:

```text
(setq *cadpoints-version* "0.6.4")
```

## Release Hygiene

Already committed release artifacts are immutable.

If the `.exe` installer implementation changes after a release commit, bump SemVer first and create a new:

```text
CadPoints_LT_Plugin_vX_Y_Z.exe
CadPoints_LT_Plugin_vX_Y_Z.zip
```

Do not rebuild an older committed `.exe` or `.zip` in place.

## Cleanup Notes

Failed installer-builder experiments may leave temporary files such as:

```text
releases\~CadPoints_LT_Plugin_vX_Y_Z.*
releases\CAB*.TMP
releases\RCX*.tmp
CAB*.TMP
```

These are local build leftovers and should not be committed.

The build script itself uses a `%TEMP%\cadpoints-exe-build-*` workspace and removes it in `finally`.

## Future Packaging Options

Keep MSI as a later enterprise/deployment target only if the self-contained EXE proves insufficient.

Possible future improvements:

- code-sign the EXE,
- add a visible installer UI with clearer success/failure messages,
- add uninstall support,
- add a Windows Defender/SmartScreen documentation note after signing/distribution decisions are made.
