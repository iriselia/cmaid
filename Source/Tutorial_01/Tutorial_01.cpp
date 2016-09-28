#include <cstdio>

// Tutorial 1: TUTORIAL_01 is defined in the CMakeLists.txt of the Tutorial_01 project
int main()
{
#ifdef TUTORIAL_01
	printf("TUTORIAL_01 is defined!\n");
#else
	printf("TUTORIAL_01 is not defined!\n");
#endif
	printf("Press any key to exit...\n");
	getchar();
	return 0;
}
