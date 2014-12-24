int main()
{
	// ExampleObject.h is force included through the .pch.h pre-compiled header
	auto pLocalObject = new ::LocalObject;
	pLocalObject->SayHi();
	delete pLocalObject;

	auto pDLLObject = new PublicDLL::DLLObject;
	// Example 0: DLLObject is accessing a private object that SampleProgram does not have access to
	pDLLObject->AccessPrivate();
	pDLLObject->SayHi();
	delete pDLLObject;

	// Example 1: PrivateLibObject is invisible in this namespace but available in the DLL.
	// See DLLObject() Constructor for details
	/*
	auto pLibObject = new PrivateLib::PrivateLibObject;
	pLibObject->SayHi();
	delete pLibObject;
	//*/
	return 0;
}
