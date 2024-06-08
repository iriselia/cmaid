#include <cstdio>
#include "Tutorial_02_Static.h"
#include "Tutorial_02_Shared.h"

// Tutorial 2: Static and shared libraries.
int main()
{
#ifdef TUTORIAL_02_STATIC
	Tutorial_02_Static_Struct StaticStruct;
	StaticStruct.PrintName();
#endif

#ifdef TUTORIAL_02_SHARED
	Tutorial_02_Shared_Struct SharedStruct;
	SharedStruct.PrintName();
#endif
	printf("Press any key to exit...\n");
	getchar();
	return 0;
}
