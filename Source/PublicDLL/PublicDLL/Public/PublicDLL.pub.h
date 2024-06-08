
// DLL common definition
#pragma once
#ifndef EXAMPLEAPI
#	ifdef IS_STATIC // Compiling .lib
#		define EXAMPLEAPI
#	else
#		ifdef IS_DYNAMIC // Compiling .dll
#			if EXPORT_ID == PROJECT_ID
#				define EXAMPLEAPI __declspec(dllexport)
#			else
#				define EXAMPLEAPI __declspec(dllimport)
#			endif
#		else // Compiling .exe
#			define EXAMPLEAPI
#		endif
#	endif
#endif

// Shareable objects must be explicitly specified
#include "Public/Object/DLLObject.h"
