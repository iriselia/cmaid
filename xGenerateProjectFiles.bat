@echo off

rem ## back up CWD
pushd "%~dp0"

if not defined CMAKE_BUILD_FLAG (
	set CMAKE_BUILD_FLAG="FULL"
)

rem ## Find Git from GitHub
for /d %%a in ("%LOCALAPPDATA%\GitHub\PortableGit*") do (set Git=%%~fa\cmd\Git.exe)
if exist "%Git%" ( goto GitFound )

rem ## Find Git for windows
if exist "%PROGRAMFILES%\Git\bin\git.exe" (
	set Git=%PROGRAMFILES%\Git\bin\git.exe
	goto GitFound
)
if exist "%PROGRAMFILES(x86)%\Git\bin\git.exe" (
	set Git=%PROGRAMFILES(x86)%\Git\bin\git.exe
	goto GitFound
)

goto Error_MissingGit
:GitFound

rem ## Find CMake or clone from Git
for %%X in (cmake.exe) do (set CMakePath=%%~$PATH:X)
if not defined CMakePath (
	IF NOT EXIST %~dp0\CMake\bin\cmake.exe (
		echo Cloning portable CMake from GitHub...
		echo.
		if not exist CMake (mkdir CMake)
		Attrib +h +s +r CMake
		"%Git%" clone https://github.com/fpark12/PortableCMake-Win32.git CMake
		echo.
	) else (
		echo Updating portable CMake...
		echo.
		pushd %~dp0\CMake\
		1>NUL "%Git%" pull https://github.com/fpark12/PortableCMake-Win32.git
		popd
		echo.
	)
	set CMakePath="%~dp0\CMake\bin\cmake.exe"
)

rem ## Find Purify or clone from Git
IF NOT EXIST %~dp0\Purify\Loader.cmake (
		mkdir Purify
		Attrib +h +s +r Purify
		echo Cloning Purify from GitHub...
		echo.
		"%Git%" clone https://github.com/fpark12/Purify.Core.git Purify
		echo.
) else (
		echo Updating Purify...
		echo.
		pushd %~dp0\Purify
		1>NUL "%Git%" pull https://github.com/fpark12/Purify.Core.git
		popd
		echo.
)

rem ## Find Visual Studio
:FindVS2017
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 15
popd
if "%VsComnToolsPath%" == "" goto FindVS2015
set CMakeArg="Visual Studio 15 2017 Win64"
goto ReadyToBuild
:FindVS2015
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 14
popd
if "%VsComnToolsPath%" == "" goto FindVS2013
set CMakeArg="Visual Studio 14 2015 Win64"
goto ReadyToBuild
:FindVS2013
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 12
popd
if "%VsComnToolsPath%" == "" goto FindVS2012
set CMakeArg="Visual Studio 12 2013 Win64"
goto ReadyToBuild
:FindVS2012
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 11
popd
if "%VsComnToolsPath%" == "" goto FindVS2010
set CMakeArg="Visual Studio 11 2012 Win64"
goto ReadyToBuild
:FindVS2010
pushd %~dp0\Purify\BatchFiles
call GetVSComnToolsPath 10
popd
if "%VsComnToolsPath%" == "" goto Error_MissingVisualStudio
set CMakeArg="Visual Studio 10 2010 Win64"
goto ReadyToBuild

call "%VsComnToolsPath%/../../VC/bin/x86_amd64/vcvarsx86_amd64.bat" >NUL

:ReadyToBuild
echo Setting up project files...
echo.
if NOT EXIST %~dp0\Build\CMakeCache.txt (
	goto InitialBuild
) else (
	goto Rebuild
)

:InitialBuild
2>NUL mkdir x64
Attrib +h +s +r x64
2>NUL mkdir Build
Attrib +h +s +r Build
pushd %~dp0\Build
rem ## build twice here because first build generates cache
"%CMakePath%" -G %CMakeArg% %~dp0 -DCMAKE_BUILD_FLAG=%CMAKE_BUILD_FLAG% || goto Error_FailedToGenerateSolution
popd
goto GenerateSolutionIcon

:Rebuild
2>NUL mkdir x64
Attrib +h +s +r x64
pushd %~dp0\Build
"%CMakePath%" -G %CMakeArg% %~dp0 -DCMAKE_BUILD_FLAG=%CMAKE_BUILD_FLAG% || goto Error_FailedToGenerateSolution
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

:RemoveAllBuild
1>NUL 2>NUL "%CMakePath%" -P "%~dp0/Purify/detail/RemoveAllBuild.cmake"

rem ## Finish up
goto GenerateSuccess

:Error_MissingGit
echo.
echo GenerateProjectFiles ERROR: It looks like you have not installed Git or GitHub. It is required for Purify to work.
echo.
pause
goto Exit

:Error_MissingVisualStudio
echo.
echo GenerateProjectFiles ERROR: It looks like you have not installed Visual Studio.
echo.
pause
goto Exit

:Error_FailedToGenerateSolution:
echo.
echo GenerateProjectFiles ERROR: Error detected while generating.
echo.
set /p "=> Press enter to regenerate or press any other key to exit... " <nul
PowerShell Exit($host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode);
set KeyCode=%ErrorLevel%
echo.
cls
if %KeyCode%==13 (
goto Rebuild
) else (
echo %KeyCode%
goto Exit
)

:GenerateSuccess
echo.
set /p "=> Project successfully generated. Press enter to regenerate or press any other key to exit... " <nul
PowerShell Exit($host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').VirtualKeyCode);
set KeyCode=%ErrorLevel%
echo.
cls
if %KeyCode%==13 (
goto Rebuild
) else (
echo %KeyCode%
goto Exit
)

:Exit
rem ## Restore original CWD in case we change it
popd

