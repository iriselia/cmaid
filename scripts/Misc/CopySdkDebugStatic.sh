#!/bin/tcsh
mkdir -p ../SDK/Include
mkdir -p ../SDK/Lib
mkdir -p ../SDK/Lib/Debug

set DIRS = `ls`
foreach dir (${DIRS})
    if (-d $dir && $dir != GraphicsFramework.xcodeproj && $dir != build) then
        echo $dir
        cd $dir
        set CURDIR = `pwd`
        set HEADERS = `ls *.h *.inl`
        foreach header (${HEADERS})
            cp -fp "${CURDIR}"/$header ../../SDK/Include
        end
        cd ..
    endif
end

set RHEADERS = `ls *.h *.inl`
foreach rheader (${RHEADERS})
    cp -fp "${SRCROOT}"/$rheader ../SDK/Include
end

cp -fp "${BUILT_PRODUCTS_DIR}"/libGraphicsFrameworkd.a ../SDK/Lib/Debug/libGraphicsFrameworkd.a
ranlib ../SDK/Lib/Debug/libGraphicsFrameworkd.a
