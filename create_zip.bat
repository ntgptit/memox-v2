@echo off
setlocal

if /i not "%~1"=="__RUN__" (
    cmd /k ""%~f0" __RUN__"
    exit /b
)

for %%I in ("%~dp0.") do set "ROOT_DIR=%%~fI"
set "OUTPUT_ZIP=%ROOT_DIR%\memox.zip"
set "PS_SCRIPT=%TEMP%\create_zip_temp_%RANDOM%_%RANDOM%.ps1"

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
echo $root = "%ROOT_DIR%"
echo $scriptFile = "%~f0"
echo $lines = Get-Content -LiteralPath $scriptFile
echo $start = [Array]::IndexOf^($lines, '::ZIP_ITEMS_BEGIN'^)
echo $end = [Array]::IndexOf^($lines, '::ZIP_ITEMS_END'^)
echo if ^($start -lt 0 -or $end -le $start^) {
echo     Write-Host "ERROR: ZIP item block was not found in create_zip.bat."
echo     exit 1
echo }
echo $itemLines = $lines[^($start + 1^)..^($end - 1^)]
echo $relativeItems = foreach ^($line in $itemLines^) {
echo     $item = $line.Trim^(^)
echo     if ^($item.Length -gt 0 -and -not $item.StartsWith^('#'^)^) { $item }
echo }
echo $paths = $relativeItems ^| Where-Object { $_.Trim^(^).Length -gt 0 } ^| ForEach-Object { Join-Path $root $_ }
echo $missingPaths = $paths ^| Where-Object { -not ^(Test-Path -LiteralPath $_^) }
echo $validPaths   = $paths ^| Where-Object { Test-Path -LiteralPath $_ }
echo if ^($missingPaths.Count -gt 0^) {
echo     Write-Host "Missing items:"
echo     $missingPaths ^| ForEach-Object { Write-Host $_ }
echo }
echo if ^($validPaths.Count -eq 0^) {
echo     Write-Host "ERROR: No valid files or folders were found to compress."
echo     exit 1
echo }
echo Compress-Archive -LiteralPath $validPaths -DestinationPath "%OUTPUT_ZIP%" -Force
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
exit /b

::ZIP_ITEMS_BEGIN
pubspec.yaml
l10n.yaml
analysis_options.yaml
lib
web/index.html
android
ios
::ZIP_ITEMS_END
