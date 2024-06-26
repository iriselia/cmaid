MACRO( CreateVSProjectSettings )
	# ONLY for msvc
	if(MSVC)
		#/FC #Full Path of Source Code File in Diagnostics
	
		# Find user and system name
		SET(SYSTEM_NAME $ENV{USERDOMAIN} CACHE STRING SystemName)
		SET(USER_NAME $ENV{USERNAME} CACHE STRING UserName)
		# Find Visual Studio Version
		if(MSVC_VERSION EQUAL 1800)
			set (TEMPLATE_MSVC_VERSION "12.0")
		endif(MSVC_VERSION EQUAL 1800)

		if((MSVC_VERSION EQUAL 1700) OR (MSVC_VERSION EQUAL 1600))
			set (TEMPLATE_MSVC_VERSION "11.0")
		endif((MSVC_VERSION EQUAL 1700) OR (MSVC_VERSION EQUAL 1600))

		if(MSVC_VERSION EQUAL 1600)
			set (TEMPLATE_MSVC_VERSION "10.0")
		endif(MSVC_VERSION EQUAL 1600)

		if(MSVC_VERSION LESS 1600)
			set (TEMPLATE_MSVC_VERSION "Unsupported version")
		endif(MSVC_VERSION LESS 1600)

		if(NOT TEMPLATE_MSVC_VERSION EQUAL "Unsupported version")
			#message("Visual Studio version: " ${TEMPLATE_MSVC_VERSION} )
		else()
			message( FATAL_ERROR "VISUAL STUDIO VERSION NOT SUPPORTED" )
		endif()
		# Configure the template file
		SET(USER_FILE ${PROJECT_NAME}.vcxproj.user)
		SET(OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/${USER_FILE})
		CONFIGURE_FILE(${CMAKE_MODULE_PATH}/Core/UserTemplate.template ${USER_FILE} @ONLY)
	endif()

	#TODO: REMOVE
	if(XCODE)
	set(CMAKE_MACOSX_RPATH 0)
	set(CMAKE_OSX_ARCHITECTURES "")
	endif()
ENDMACRO()