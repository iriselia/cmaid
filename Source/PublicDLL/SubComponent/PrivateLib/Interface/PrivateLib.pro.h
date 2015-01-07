/*
Everything in this file will be available to the modules that include
PrivateLib. In our case, the CMakeLists.txt in PublicDLL makes PrivateLib.pro.h
Auto-included for PublicDLL.
*/
// Shareable objects must be explicitly specified
#include "Public/Object/PrivateLibObject.h"
