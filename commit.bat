@echo off
setlocal enabledelayedexpansion

rem Use PowerShell to list files with 3-4 digit numeric extensions and sort numerically
for /f "usebackq delims=" %%F in (`powershell -NoProfile -Command "Get-ChildItem -File -Name 'models.zip.*' | Where-Object { $_ -match '\.(\d{3,4})$' } | Sort-Object { [int]($_ -replace '.*\.', '') }"`) do (
    set "file=%%F"
    rem extension with leading dot (e.g. .100)
    set "ext_raw=%%~xF"
    rem remove leading dot
    set "ext_raw=!ext_raw:~1!"
    rem pad to 4 digits
    set "ext=0000!ext_raw!"
    set "ext=!ext:~-4!"

    git add -- "!file!"
    git commit -m "!file!"
    git push -f origin HEAD:!ext!
    echo Pushed !file! to branch !ext!
    del /q "!file!"
)

git push -f origin HEAD:main

endlocal
