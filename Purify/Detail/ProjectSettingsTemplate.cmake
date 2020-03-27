MACRO( CreateVSProjectSettings )
	# ONLY for msvc
	if(MSVC)
		#/FC #Full Path of Source Code File in Diagnostics
	
		# Find user and system name
		SET(SYSTEM_NAME $ENV{USERDOMAIN} CACHE STRING SystemName)
		SET(USER_NAME $ENV{USERNAME} CACHE STRING UserName)
		# Set architecture
		if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
		#MESSAGE( "64 bits compiler detected" )
		set(TEMPLATE_WINDOWS_ARCH_VERSION "x64")
		else( CMAKE_SIZEOF_VOID_P EQUAL 8 ) 
		#MESSAGE( "32 bits compiler detected" )
		set(TEMPLATE_WINDOWS_ARCH_VERSION "Win32")
		
		endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
		# Find Visual Studio Version
		if(MSVC_VERSION EQUAL 1900)
			set (TEMPLATE_MSVC_VERSION "13.0")
		endif(MSVC_VERSION EQUAL 1900)

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
		CONFIGURE_FILE(${CMAKE_MODULE_PATH}/Detail/UserTemplate.template ${USER_FILE} @ONLY)
	endif()

	#TODO: REMOVE
	if(XCODE)
	set(CMAKE_OSX_ARCHITECTURES "")
	endif()
ENDMACRO()