@echo off

rem ## back up CWD
pushd "%~dp0"

rem ## Find Git from GitHub
for /d %%a in ("%APPDATA%\..\Local\GitHub\PortableGit*") do (set Git=%%~fa\bin\Git.exe)
if Git == "" ( goto Error_MissingGitHub )

rem ## Find CMake or clone from Git
for %%X in (cmake.exe) do (set CMakePath=%%~$PATH:X)
if not defined CMakePath (
	IF NOT EXIST %~dp0\CMake\bin\cmake.exe (
		echo Purify is cloning a portable CMake from GitHub...
		echo.
		mkdir CMake
		Attrib +h +s +r CMake
		%Git% clone https://github.com/piaoasd123/PortableCMake-Win32.git CMake
		echo.
	)
	set CMakePath="%~dp0\CMake\bin\cmake.exe"
)

rem ## Find Purify or clone from Git
IF NOT EXIST %~dp0\Purify (
		mkdir Purify
		Attrib +h +s +r Purify
		echo Purify is cloning itself from GitHub...
		echo.
		"%Git%" clone https://github.com/piaoasd123/Purify.git
		echo.
) else (
		echo Purify is updating...
		echo.
		pushd %~dp0\Purify\
		1>NUL "%Git%" pull https://github.com/piaoasd123/Purify.git
		popd
		echo.
)

rem ## Find Visual Studio 2013 Full & Express
:FindVS2015
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 14
popd
if "%VsComnToolsPath%" == "" goto FindVS2013
set CMakeArg="Visual Studio 14 2015"
goto ReadyToBuild
:FindVS2013
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 12
popd
if "%VsComnToolsPath%" == "" goto FindVS2012
set CMakeArg="Visual Studio 12 2013"
goto ReadyToBuild
:FindVS2012
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 11
popd
if "%VsComnToolsPath%" == "" goto FindVS2010
set CMakeArg="Visual Studio 11 2012"
goto ReadyToBuild
:FindVS2010
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 10
popd
if "%VsComnToolsPath%" == "" goto Error_MissingVisualStudio
set CMakeArg="Visual Studio 10 2010"
goto ReadyToBuild

call "%VsComnToolsPath%/../../VC/bin/x86_amd64/vcvarsx86_amd64.bat" >NUL
:ReadyToBuild
echo Purify is setting up project files...
if NOT EXIST %~dp0\Build (
	goto InitialBuild
) else (
	goto Rebuild
)

:InitialBuild
2>NUL mkdir Build
Attrib +h +s +r Build
pushd %~dp0\Build
rem ## build twice here because first build generates cache
1>NUL 2>NUL "%CMakePath%" -G %CMakeArg% %~dp0
1>NUL 2>NUL "%CMakePath%" -G %CMakeArg% %~dp0
popd
goto GenerateSolutionIcon

:Rebuild
pushd %~dp0\Build
1>NUL 2>NUL "%CMakePath%" -G %CMakeArg% %~dp0
popd
goto GenerateSolutionIcon

:GenerateSolutionIcon
for %%* in (.) do set CurrDirName=%%~n*
for /f "delims=" %%A in ('cd') do (set foldername=%%~nxA)

set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%CD%\zz%CurrDirName%.sln.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "%CD%\Build\%CurrDirName%.sln" >> %SCRIPT%
echo oLink.IconLocation = "%SystemRoot%\system32\vsjitdebugger.exe, 0" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%

cscript /nologo %SCRIPT%
del %SCRIPT%

rem ## Finish up
goto Exit

:Error_MissingGitHub
echo.
echo GenerateProjectFiles ERROR: It looks like you have not installed GitHub. It is required for Purify to work.
echo.
pause
goto Exit

:Error_MissingVisualStudio
echo.
echo GenerateProjectFiles ERROR: It looks like you have not installed Visual Studio.
echo.
pause
goto Exit


:Exit
rem ## Restore original CWD in case we change it
popd