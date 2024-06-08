@echo off

pushd %~dp0\..

rem ## Find Visual Studio
:FindVS2019
pushd .\Purify\Misc
call GetVSComnToolsPath 16
popd
if "%VsComnToolsPath%" == "" goto FindVS2017
set CMakeArg="Visual Studio 16 2019"
goto ReadyToBuild
:FindVS2017
pushd .\Purify\Misc
call GetVSComnToolsPath 15
popd
if "%VsComnToolsPath%" == "" goto FindVS2015
set CMakeArg="Visual Studio 15 2017 Win64"
goto ReadyToBuild
:FindVS2015
pushd .\Purify\Misc
call GetVSComnToolsPath 14
popd
if "%VsComnToolsPath%" == "" goto FindVS2013
set CMakeArg="Visual Studio 14 2015 Win64"
goto ReadyToBuild
:FindVS2013
pushd .\Purify\Misc
call GetVSComnToolsPath 12
popd
if "%VsComnToolsPath%" == "" goto FindVS2012
set CMakeArg="Visual Studio 12 2013 Win64"
goto ReadyToBuild
:FindVS2012
pushd .\Purify\Misc
call GetVSComnToolsPath 11
popd
if "%VsComnToolsPath%" == "" goto FindVS2010
set CMakeArg="Visual Studio 11 2012 Win64"
goto ReadyToBuild
:FindVS2010
pushd .\Purify\Misc
call GetVSComnToolsPath 10
popd
if "%VsComnToolsPath%" == "" goto Error_MissingVisualStudio
set CMakeArg="Visual Studio 10 2010 Win64"
goto ReadyToBuild

call "%VsComnToolsPath%/../../VC/bin/x86_amd64/vcvarsx86_amd64.bat" >NUL

:ReadyToBuild
echo Setting up project files...
echo.
if NOT EXIST .\Build\CMakeCache.txt (
	goto InitialBuild
) else (
	goto Rebuild
)

:InitialBuild
2>NUL mkdir x64
Attrib +h +s +r x64
2>NUL mkdir Build
Attrib +h +s +r Build
pushd .\Build
"%CMakePath%" -G %CMakeArg% .. -DCMAKE_BUILD_FLAG=%CMAKE_BUILD_FLAG% || goto Error_FailedToGenerateSolution
popd
goto GenerateSolutionIcon

:Rebuild
2>NUL mkdir x64
Attrib +h +s +r x64
pushd .\Build
"%CMakePath%" -G %CMakeArg% .. -DCMAKE_BUILD_FLAG=%CMAKE_BUILD_FLAG% || goto Error_FailedToGenerateSolution
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
1>NUL 2>NUL "%CMakePath%" -P "./Purify/detail/RemoveAllBuild.cmake"

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

