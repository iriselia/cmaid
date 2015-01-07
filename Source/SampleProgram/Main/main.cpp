
// Example 0: EXAMPLE_MACRO is defined in the CMakeLists.txt of SampleProgram
#ifdef EXAMPLE_MACRO
int main()
{
	// ExampleObject.h is force included through the .pch.h pre-compiled header
	auto pLocalObject = new ::LocalObject;
	pLocalObject->SayHi();
	delete pLocalObject;

	/*
	Example 1: Pre-compiled header.

	PublicDLL is included through SampleProgram.pch.h and SampleProgram.pch.cpp.
	Any *.pch.h and *.pch.cpp source files are treated as pre-compiled and will
	be force-included by Visual Studio.
	*/
	auto pDLLObject = new PublicDLL::DLLObject;
	/*
	Example 2 Part 1: Module visibility.

	The implementation of AccessPrivate() involves accessing PrivateLibObject which is
	invisible to SampleProgram. It is because the CMakeLists.txt in SampleProgram
	defines SampleProgram only contains	include directories for PublicDLL.
	*/
	pDLLObject->AccessPrivate();
	pDLLObject->SayHi();
	delete pDLLObject;

	/* 
	Example 2 Part 2: Module visibility.
	Activating the code below should cause an error, because PrivateLibObject is
	invisible in this namespace but available to PublicDLL.
	See DLLObject() Constructor for details. 
	*/
	/* Comment this line to activate the code: "// /*"
	auto pLibObject = new PrivateLib::PrivateLibObject;
	pLibObject->SayHi();
	delete pLibObject;
	//*/

	printf("\nPress any key to exit...\n");
	getchar();
	return 0;
}
#endif