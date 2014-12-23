@echo off
mkdir Build
cd Build
"cmake.exe" -G "Visual Studio 12 2013" ../
cd ../

for %%* in (.) do set CurrDirName=%%~n*
for /f "delims=" %%A in ('cd') do (set foldername=%%~nxA)

set SCRIPT="%TEMP%\%RANDOM%-%RANDOM%-%RANDOM%-%RANDOM%.vbs"


echo Set oWS = WScript.CreateObject("WScript.Shell") >> %SCRIPT%
echo sLinkFile = "%CD%\%CurrDirName%.sln.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "%CD%\Build\%CurrDirName%.sln" >> %SCRIPT%
echo oLink.IconLocation = "%SystemRoot%\system32\vsjitdebugger.exe, 0" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%

cscript /nologo %SCRIPT%
del %SCRIPT%

echo "Finishing up..."
pause