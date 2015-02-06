#pragma once
namespace PublicDLL
{
	class DLLObject
	{
	public:
		EXAMPLEAPI DLLObject();
		EXAMPLEAPI ~DLLObject();

		EXAMPLEAPI void AccessPrivate();
		EXAMPLEAPI void SayHi();
	private:

	};
}
