@echo off
for /d %%a in ("%APPDATA%\..\Local\GitHub\PortableGit*") do (set GitPath=%%~fa)
set GitPath="%GitPath%\bin\Git.exe"

for %%X in (cmake.exe) do (set CMakePath=%%~$PATH:X)
if not defined CMakePath (
	"%GitPath%" "clone" "https://github.com/piaoasd123/PortableCMake-Win32.git"
	set CMakePath="%~dp0\PortableCMake-Win32\bin\cmake.exe"
)

mkdir Build
cd Build
REM "%CMakePath%" -G "Visual Studio 10 2010" ../
"%CMakePath%" -G "Visual Studio 11 2012" ../
"%CMakePath%" -G "Visual Studio 12 2013" ../
REM "%CMakePath%" -G "Visual Studio 14 2015" ../
cd ../

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

echo "Finishing up..."