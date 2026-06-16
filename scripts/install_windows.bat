@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem CadPoints Windows installer for non-technical users.
rem Installs CadPoints.bundle into %%APPDATA%%\Autodesk\ApplicationPlugins
rem without requiring administrative rights.

set "SCRIPT_DIR=%~dp0"
set "REQUESTED_SOURCE=%~1"
set "REQUESTED_DEST_ROOT=%~2"

if not defined REQUESTED_DEST_ROOT (
    set "DEST_ROOT=%APPDATA%\Autodesk\ApplicationPlugins"
) else (
    set "DEST_ROOT=%~2"
)

call :resolve_source
if errorlevel 1 goto :fail

set "DEST_BUNDLE=%DEST_ROOT%\CadPoints.bundle"

if not exist "%DEST_ROOT%" (
    mkdir "%DEST_ROOT%" >nul 2>&1
    if errorlevel 1 (
        echo Nelze vytvorit cilovou slozku:
        echo "%DEST_ROOT%"
        goto :fail
    )
)

if exist "%DEST_BUNDLE%" (
    attrib -r -s -h "%DEST_BUNDLE%\*" /s /d >nul 2>&1
    rmdir /s /q "%DEST_BUNDLE%"
)

robocopy "%SOURCE_BUNDLE%" "%DEST_BUNDLE%" /E /NFL /NDL /NJH /NJS /NP >nul
set "ROBOCODE=%ERRORLEVEL%"

if %ROBOCODE% GEQ 8 (
    echo Kopirovani selhalo. Robocopy vratil chybovy kod %ROBOCODE%.
    goto :fail
)

if not exist "%DEST_BUNDLE%\PackageContents.xml" (
    echo Instalace selhala. Chybi PackageContents.xml v cilove slozce.
    goto :fail
)

set "DEFAULT_DEST_ROOT=%APPDATA%\Autodesk\ApplicationPlugins"
if /I "%DEST_ROOT%"=="%DEFAULT_DEST_ROOT%" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%DEST_BUNDLE%\Contents\Install\configure_autocad_profile.ps1" -BundlePath "%DEST_BUNDLE%"
    if errorlevel 1 (
        echo Instalace souboru probehla, ale konfigurace AutoCAD LT profilu selhala.
        goto :fail
    )
)

if /I not "%DEST_ROOT%"=="%DEFAULT_DEST_ROOT%" (
    echo Konfigurace AutoCAD LT profilu preskocena pro vlastni cilovou slozku.
)

echo CadPoints bylo nainstalovano.
echo Zdroj: %SOURCE_BUNDLE%
echo Cil:   %DEST_BUNDLE%
echo Restartuj AutoCAD LT 2026.1.1 (W.164.0.0), aby se balicek nacetl.
exit /b 0

:resolve_source
set "SOURCE_BUNDLE="

if defined REQUESTED_SOURCE (
    call :check_candidate "%REQUESTED_SOURCE%"
    if defined SOURCE_BUNDLE exit /b 0
)

call :check_candidate "%SCRIPT_DIR%..\dist\CadPoints.bundle"
if defined SOURCE_BUNDLE exit /b 0

call :check_candidate "%SCRIPT_DIR%..\src\CadPoints.bundle"
if defined SOURCE_BUNDLE exit /b 0

call :check_candidate "%SCRIPT_DIR%..\CadPoints.bundle"
if defined SOURCE_BUNDLE exit /b 0

call :check_candidate "%CD%\CadPoints.bundle"
if defined SOURCE_BUNDLE exit /b 0

call :check_candidate "%CD%\dist\CadPoints.bundle"
if defined SOURCE_BUNDLE exit /b 0

call :check_candidate "%CD%\src\CadPoints.bundle"
if defined SOURCE_BUNDLE exit /b 0

echo Nenalezen zdrojovy CadPoints.bundle.
echo Spust skript z korene repozitare nebo poloz vedle nej slozku CadPoints.bundle.
exit /b 1

:check_candidate
set "CANDIDATE=%~1"
if exist "%CANDIDATE%\PackageContents.xml" (
    for %%I in ("%CANDIDATE%") do set "SOURCE_BUNDLE=%%~fI"
    exit /b 0
)
exit /b 1

:fail
exit /b 1
