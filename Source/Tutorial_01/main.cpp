#include <cstdio>

// Tutorial 1: EXAMPLE_MACRO is defined in the CMakeLists.txt of the Tutorial_01 project
int main()
{
#ifdef EXAMPLE_MACRO
	printf("EXAMPLE_MACRO is defined!\n");
#else
	printf("EXAMPLE_MACRO is not defined!\n");
#endif
	printf("Press any key to exit...\n");
	getchar();
	return 0;
}
