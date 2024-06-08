cmake_minimum_required( VERSION 2.8 )

# function(AddDotNetReferences IN_REFERENCES)
#
#
#
MACRO(AddDotNetReferences references)
	#.NET REFERENCES
	set_target_properties(${PROJECT_NAME} PROPERTIES VS_DOTNET_REFERENCES "${references}")
	set_target_properties(${PROJECT_NAME} PROPERTIES COMPILE_FLAGS "/clr /EHa")
	
	# Must disable RTC1 for CLR
	if(CMAKE_CXX_FLAGS_DEBUG MATCHES "/RTC1")
	   string(REPLACE "/RTC1" " " CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
	endif()

	if(CMAKE_CXX_FLAGS MATCHES "/EHsc")
	   string(REPLACE "/EHsc" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
	endif()
ENDMACRO(AddDotNetReferences OUT_NAME)