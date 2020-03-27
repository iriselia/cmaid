@echo off

rem ## back up CWD
pushd "%~dp0"

if not defined CMAKE_BUILD_FLAG (
	set CMAKE_BUILD_FLAG="FULL"
)

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

echo Warning: Git not found.
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
		"%Git%" clone https://github.com/jpark730/PortableCMake-Win32.git CMake
		echo.
	) else (
		echo Updating portable CMake...
		echo.
		pushd %~dp0\CMake\
		1>NUL "%Git%" pull https://github.com/jpark730/PortableCMake-Win32.git
		popd
		echo.
	)
	set CMakePath="%~dp0\CMake\bin\cmake.exe"
)

rem ## Find cmaid or clone from Git
IF NOT EXIST %~dp0\Scripts\Loader.cmake (
		mkdir cmaid
		Attrib +h +s +r cmaid
		echo Cloning cmaid from GitHub...
		echo.
		pushd %~dp0\..\
		"%Git%" clone https://github.com/jpark730/cmaid.git cmaid
		popd
		echo.
) else (
		echo Updating cmaid...
		echo.
		1>NUL "%Git%" submodule update
		popd
		echo.
)

rem Purify/GenerateProjectFiles.bat

:Exit
rem ## Restore original CWD in case we change it
popd

