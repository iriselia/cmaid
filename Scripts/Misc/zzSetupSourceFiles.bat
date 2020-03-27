for %%* in (.) do set CurrDirName=%%~n*

mkdir Source
cd Source
mkdir Private
mkdir Public
cd ..

mkdir Shaders
cd Shaders
mkdir %CurrDirName%
cd ..

move /-y %CD%\*.cpp %CD%\Source\Private
move /-y %CD%\*.h %CD%\Source\Public
move /-y %CD%\*.glsl %CD%\Shaders\%CurrDirName%

pause