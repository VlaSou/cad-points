# AutoCAD LT Local Findings

Date: 2026-06-08

This file records AutoCAD LT installation and CadPoints plug-in loading findings for local and future agents.

## Official AppAutoloader Rules

Autodesk documents AutoCAD plug-ins as `.bundle` folders with a `PackageContents.xml` file. `PackageContents.xml` controls the supported AutoCAD-based products, AutoCAD LT compatibility, operating systems, releases, languages, and loading behavior.

Primary Autodesk web references used:

```text
https://help.autodesk.com/cloudhelp/2024/ENU/AutoCAD-Customization/files/GUID-BC76355D-682B-46ED-B9B7-66C95EEF2BD0.htm
https://blog.autodesk.io/autocad-2025-update-your-packagecontentsxml-with-runtimerequirements/
```

Important conclusion for CadPoints:

- `PackageContents.xml` is the metadata file AutoCAD uses to decide whether and how a bundle loads.
- `RuntimeRequirements` is the relevant place to constrain operating system, AutoCAD platform, release/series, and language compatibility.
- Do not install CadPoints into a year-specific AutoCAD LT program folder.
- The default no-admin install target should remain the user-level AppAutoloader folder:

```text
%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle
```

- A machine-wide install can use:

```text
%PROGRAMDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle
```

- Version targeting belongs in `PackageContents.xml`, especially `RuntimeRequirements`, not in the installer destination path.

Secondary web references found during research also describe the same AppAutoloader folder convention:

```text
https://civilwhiz.com/docs/exploring-the-packagecontents-xml-and-autocad-plugin-structure/
https://forums.autodesk.com/t5/net-forum/autoloader-dont-work/td-p/4459739
https://www.augi.com/articles/detail/the-autodesk-exchange-apps-store
```

Treat Autodesk Help and Autodesk Developer Blog as primary sources. Treat community/blog references as supporting context only.

## Local Workstation Detection

The workstation currently has AutoCAD LT 2026 registry/uninstall entries.

User-provided local permission note:

- The `D:\Autodesk\` folder contains a clean AutoCAD LT trial installation.
- The trial currently has 9 days remaining as of 2026-06-08.
- Agents may make changes under `D:\Autodesk\` at their discretion when needed for CadPoints verification.
- Prefer targeted verification changes only; do not reinstall, repair, or upgrade AutoCAD unless the user explicitly asks for that operation.

Detected uninstall entries:

```text
AutoCAD LT Private                              25.1.60.0    D:\Autodesk\AutoCAD LT 2026\
AutoCAD LT 2026 - Czech                        25.1.60.0    D:\Autodesk\AutoCAD LT 2026\
Autodesk AutoCAD LT 2026.1.1 Update             25.1.164.0   D:\Autodesk
Autodesk AutoCAD LT 2026 - Czech language data  25.1.164.0   D:\Autodesk
```

Detected executable:

```text
D:\Autodesk\AutoCAD LT 2026\acadlt.exe
```

Not found in this session:

```text
where acadlt
C:\Program Files\Autodesk\...\acadlt.exe
```

Registry keys observed:

```text
HKLM\SOFTWARE\Autodesk\AutoCAD LT\R32\ACADLT-9101
HKLM\SOFTWARE\Autodesk\AutoCAD LT\R32\ACADLT-9101:405
HKCU\SOFTWARE\Autodesk\AutoCAD LT\R32\ACADLT-9101:405
```

The `:405` suffix indicates Czech locale data for this local AutoCAD LT profile.

## Version And Folder Map

For AppAutoloader `.bundle` plug-ins, the install folder does not need a per-version map:

| Scope | Expected plug-in folder |
| --- | --- |
| Current user | `%APPDATA%\Autodesk\ApplicationPlugins\<PluginName>.bundle` |
| All users | `%PROGRAMDATA%\Autodesk\ApplicationPlugins\<PluginName>.bundle` |

AutoCAD LT version/profile-specific data is separate. CUIx/support/profile paths commonly live under user AutoCAD profile folders, for example:

```text
%APPDATA%\Autodesk\AutoCAD LT <year>\<series>\<locale>\...
```

Do not hardcode these profile paths unless runtime testing confirms the exact local value. Prefer AutoCAD commands such as `CUI`, `CUILOAD`, `APPAUTOLOADER`, `TRUSTEDPATHS`, and `APPLOAD` for verification.

## Web-Researched Version / Series Notes

The web research found one useful public series example from an Autodesk support article:

```text
AutoCAD 2026: RuntimeRequirements SeriesMin/SeriesMax R25.x
AutoCAD 2027: RuntimeRequirements SeriesMin/SeriesMax R26.x
```

Reference:

```text
https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/The-AutoCAD-2027-Vault-Add-in-is-disabled-when-Vault-and-AutoCAD-2026-are-installed-as-well.html
```

Local workstation registry uses:

```text
AutoCAD LT 2026: HKLM\SOFTWARE\Autodesk\AutoCAD LT\R32\ACADLT-9101
AutoCAD LT 2026 Czech profile: HKLM/HKCU ...\ACADLT-9101:405
```

Do not infer AppAutoloader install directories from these series/profile keys. Use them only for diagnostics and detection/reporting.

## Ribbon / Panel Findings

Autodesk CUI documentation says UI customization is stored in CUIx files. `CUI` manages UI elements such as ribbon panels, toolbars, menus, shortcuts, and workspaces. `CUILOAD` loads CUIx customization files.

Primary Autodesk references:

```text
https://help.autodesk.com/cloudhelp/2024/ENU/AutoCAD-LT/files/GUID-7F8F4B26-EFAF-4033-B7B7-CA39FC4E104A.htm
https://help.autodesk.com/cloudhelp/2023/ENU/AutoCAD-LT/files/GUID-B5969D87-7FE8-47B4-A02F-38E7897A6CB4.htm
https://help.autodesk.com/cloudhelp/2023/ENU/AutoCAD-Customization/files/GUID-D148C822-34AC-4A12-897A-60742F375406.htm
```

Additional Autodesk LT customization references:

```text
https://help.autodesk.com/cloudhelp/2024/ENU/AutoCAD-LT-Customization/files/GUID-D148C822-34AC-4A12-897A-60742F375406.htm
https://help.autodesk.com/cloudhelp/2020/ENU/AutoCAD-Customization/files/GUID-55B0E62E-9F40-4A95-BCE6-180EB47C9DDD.htm
https://help.autodesk.com/cloudhelp/2024/ENU/AutoCAD-LT-Customization/files/GUID-FE301EEC-11BD-4243-8263-2CDDD3FA02C0.htm
```

Important conclusion for CadPoints:

- CadPoints currently ships `Contents/Menu/cadpoints.mnu`, but modern AutoCAD LT expects XML-based CUIx customization files for loaded UI customizations.
- Autodesk states that legacy MNS/MNU/CUI files have been replaced by XML-based CUIx files for modern customization loading.
- Partial CUIx files can be created and loaded through the CUI editor, and CUIx files can also be loaded/unloaded from the command prompt through `CUILOAD` / `CUIUNLOAD`.
- A generated binary `.cuix` should not be claimed release-ready unless it is created and tested inside AutoCAD LT.
- The safe current path is:
  - install the `.bundle`,
  - verify commands through `APPAUTOLOADER` / `APPLOAD`,
  - create or load panel customizations through `CUI` / `CUILOAD` during runtime verification.

AutoCAD LT-specific AutoLISP/CUI note found on Autodesk Help:

```text
https://help.autodesk.com/cloudhelp/2025/ENU/AutoCAD-LT-Customization/files/GUID-830DF85D-4722-4B09-A311-D356C975E368.htm
```

Autodesk notes that AutoCAD LT does not support automatic MNL loading with CUIx files in the same way as full AutoCAD. CadPoints should keep LISP loading in the `.bundle` AppAutoloader path and not rely on an MNL sidecar for LT.

## Automation Direction

Installer automation should be improved conservatively:

1. Detect installed AutoCAD LT versions from uninstall registry entries and common executable paths.
2. Report detected versions and executable paths to the user.
3. Install CadPoints to `%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle` by default.
4. Avoid copying plug-in files into AutoCAD LT program folders.
5. Avoid silently editing user CUIx/profile files.
6. If panel automation is added, make it an explicit, separately verified AutoCAD LT workflow and record results in `docs/runtime-test-checklist.md`.

Runtime automation note from 2026-06-16:

- AutoCAD LT may stop before `/b` script execution on the license/unregistered-version dialog.
- Close that dialog first; then the pending `/b` script continues.
- If AutoCAD asks whether to save the generated test drawing, answer `No`.
- Do not leave old `acadlt.exe` instances open between attempts.
- AutoCAD LT can also show an unsigned executable-file prompt for `Contents/Test/cadpoints_runtime_smoke_test.lsp` when `SECURELOAD` is enabled and the bundle path is not trusted.
- Prefer adding `CadPoints.bundle\...` to `TRUSTEDPATHS`; do not globally disable `SECURELOAD`.
- The bundled `Contents/Test/cadpoints_runtime_smoke.scr` sets that trusted path before loading the smoke-test LISP.

Packaging note:

- The current ZIP should keep `install_windows.bat` at the archive root next to `CadPoints.bundle`, not inside `CadPoints.bundle`.
- A self-contained `.exe` installer is the preferred next user-facing packaging target.
- MSI is better treated as a later enterprise deployment target, not the immediate default.

Web-researched automation conclusion:

- It is reasonable for the installer to detect and print installed AutoCAD LT versions, executable paths, and registry keys.
- It is not correct to choose a different `.bundle` install path per AutoCAD LT year.
- Automatic ribbon/panel installation should wait for a tested partial `.cuix`; the current `.mnu` file is useful as a menu template/reference but should not be treated as a modern automatic panel installer.

## Runtime Verification Commands

After install and AutoCAD LT restart:

```text
APPAUTOLOAD
APPAUTOLOADER
SECURELOAD
TRUSTEDPATHS
APPLOAD
CPHELP
CPSETTINGS
CPEXPORT
CUI
CUILOAD
```

Do not claim AutoCAD LT runtime verification until the commands were actually run in AutoCAD LT.
