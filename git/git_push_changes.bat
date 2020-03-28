@echo off

rem ## back up CWD
pushd "%~dp0"

rem ## Find Git from old GitHubDesktop
for /d %%a in ("%LOCALAPPDATA%\GitHub\PortableGit*") do (set Git=%%~fa\cmd\Git.exe)
if exist "%Git%" ( goto GitFound )

rem ## Find Git from new GitHubDesktop
for /d %%a in ("%LOCALAPPDATA%\GitHubDesktop\app*") do (set Git=%%~fa\resources\app\git\cmd\Git.exe)
if exist "%Git%" ( goto GitFound )

rem ## Find Git for windows
if exist "%PROGRAMFILES%\Git\bin\git.exe" (
	set Git="%PROGRAMFILES%\Git\bin\git.exe"
	goto GitFound
)
if exist "%PROGRAMFILES(x86)%\Git\bin\git.exe" (
	set Git="%PROGRAMFILES(x86)%\Git\bin\git.exe"
	goto GitFound
)

if Git == "" ( goto Error_MissingGitHub )

:GitFound
"%Git%" add --all
"%Git%" commit -m "PushChanges.bat..."
"%Git%" push

pause
Exit

:Error_MissingGitHub
echo.
echo GenerateProjectFiles ERROR: It looks like you have not installed GitHub. It is required for Purify to work.
echo.
pause
goto Exit

