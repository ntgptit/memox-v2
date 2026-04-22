@echo off
setlocal

if /i not "%~1"=="__RUN__" (
    cmd /k ""%~f0" __RUN__"
    exit /b
)

set "ROOT_DIR=D:\workspace_STS_5\memox"
set "OUTPUT_ZIP=%ROOT_DIR%\memox.zip"
set "PS_SCRIPT=%TEMP%\create_zip_temp.ps1"

set "ITEM1=%ROOT_DIR%\pubspec.yaml"
set "ITEM2=%ROOT_DIR%\l10n.yaml"
set "ITEM3=%ROOT_DIR%\devtools_options.yaml"
set "ITEM4=%ROOT_DIR%\analysis_options.yaml"
set "ITEM5=%ROOT_DIR%\lib"
@REM set "ITEM6=%ROOT_DIR%\tools"
@REM set "ITEM7=%ROOT_DIR%\.codex"

echo ==========================================
echo Zip script started
echo ==========================================
echo Root directory: %ROOT_DIR%
echo Output archive: %OUTPUT_ZIP%
echo.

if not exist "%ROOT_DIR%" (
    echo ERROR: Root directory does not exist.
    goto :END
)

if exist "%OUTPUT_ZIP%" (
    echo Deleting existing archive...
    del /f /q "%OUTPUT_ZIP%"
    if errorlevel 1 (
        echo ERROR: Failed to delete existing archive.
        goto :END
    )
)

(
echo $ErrorActionPreference = 'Stop'
echo $paths = @(
echo     "%ITEM1%"
echo     "%ITEM2%"
echo     "%ITEM3%"
echo     "%ITEM4%"
echo     "%ITEM5%"
@REM echo     "%ITEM6%"
@REM echo     "%ITEM7%"
echo ^)
echo $missingPaths = $paths ^| Where-Object { -not ^(Test-Path $_^) }
echo $validPaths   = $paths ^| Where-Object { Test-Path $_ }
echo if ^($missingPaths.Count -gt 0^) {
echo     Write-Host "Missing items:"
echo     $missingPaths ^| ForEach-Object { Write-Host $_ }
echo }
echo if ^($validPaths.Count -eq 0^) {
echo     Write-Host "ERROR: No valid files or folders were found to compress."
echo     exit 1
echo }
echo Compress-Archive -Path $validPaths -DestinationPath "%OUTPUT_ZIP%" -Force
echo Write-Host "Archive created successfully:"
echo Write-Host "%OUTPUT_ZIP%"
) > "%PS_SCRIPT%"

echo Running compression...
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"
if errorlevel 1 (
    echo ERROR: Compression failed.
    del /f /q "%PS_SCRIPT%" >nul 2>&1
    goto :END
)

del /f /q "%PS_SCRIPT%" >nul 2>&1

echo.
echo SUCCESS: Archive created successfully.

:END
echo.
echo Press any key to close this window...
pause > nul