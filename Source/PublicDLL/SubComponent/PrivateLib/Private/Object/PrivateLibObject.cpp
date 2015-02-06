#if defined(__APPLE__)
#include <PrivateLib.generated.pch.h>
#include <PrivateLib.pri.h>
#endif

namespace PrivateLib
{
	PrivateLibObject::~PrivateLibObject()
	{

	}

	PrivateLibObject::PrivateLibObject()
	{

	}

	void PrivateLibObject::SayHi()
	{
		printf("Hello! I am from PrivateLib!\n");
	}
}
