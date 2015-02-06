#if defined(__APPLE__)
#include <SampleProgram.generated.pch.h>
#include <SampleProgram.pri.h>
#endif

LocalObject::~LocalObject()
{

}

LocalObject::LocalObject()
{

}

void LocalObject::SayHi()
{
	printf("Hello! I am from SampleProgram!\n");
}
