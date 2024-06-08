@echo off

rem ## back up CWD
pushd "%~dp0"

rem ## Find Git from GitHub
for /d %%a in ("%LOCALAPPDATA%\GitHub\PortableGit*") do (set Git=%%~fa\cmd\Git.exe)
if Git == "" ( goto Error_MissingGitHub )

pause

"%Git%" reset --hard

pause
Exit

:Error_MissingGitHub
echo.
echo GenerateProjectFiles ERROR: It looks like you have not installed GitHub. It is required for Purify to work.
echo.
pause
goto Exit

