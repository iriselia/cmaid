#----- Flex and Bison -----
if( USE_FLEX_AND_BISON AND NOT FLEX_EXECUTABLE STREQUAL "" AND NOT BISON_EXECUTABLE STREQUAL "")
	file(GLOB_RECURSE MY_FLEX_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.l)
	file(GLOB_RECURSE MY_BISON_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.y)
	# remove extension from .l and .y files
	REMOVE_FILE_EXTENSION(${MY_FLEX_FILES} flexFiles)
	REMOVE_FILE_EXTENSION(${MY_BISON_FILES} bisonFiles)

	SET( FLEX_EXECUTABLE1 "${CMAKE_SOURCE_DIR}/3rdParty/FlexBison/bin/flex.exe")
	SET( BISON_EXECUTABLE1 "${CMAKE_SOURCE_DIR}/3rdParty/FlexBison/bin/bison.exe")
	SET( FlexArgs "-o${MY_FLEX_FILES}.flex.c" "${MY_FLEX_FILES}.l")
	SET( BisonArgs "-o${MY_BISON_FILES}.bison.c" "-d" "${MY_BISON_FILES}.y" )
	
	#[[
	# Create target for the parser
	ADD_CUSTOM_TARGET(${PROJECT_NAME}Flex ALL
		COMMAND ${FLEX_EXECUTABLE} 
		-o"${flexFiles}.flex.c"
		"${flexFiles}.l"
		COMMENT "Creating .flex.c")
		
	ADD_CUSTOM_TARGET(${PROJECT_NAME}Bison ALL
		COMMAND ${BISON_EXECUTABLE}
		-o"${bisonFiles}.bison.c"
		-d "${bisonFiles}.y"
		COMMENT "Creating .bison.c")
	add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}Flex)
	add_dependencies(${PROJECT_NAME}Flex ${PROJECT_NAME}Bison)
	 
	if( MSVC )
		SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
		SET_PROPERTY(TARGET ${PROJECT_NAME}Flex		PROPERTY FOLDER CMakePredefinedTargets)
		SET_PROPERTY(TARGET ${PROJECT_NAME}Bison		PROPERTY FOLDER CMakePredefinedTargets)
	endif()
	]]#
	
	
	ADD_CUSTOM_TARGET(${PROJECT_NAME}FlexBison echo "Generating Flex & Bison source files")
		
	ADD_CUSTOM_COMMAND(
	   DEPENDS ${flexFiles}.l
	   COMMAND ${FLEX_EXECUTABLE}
	   ARGS -o"${flexFiles}.flex.c"
			"${flexFiles}.l"
	   TARGET ${PROJECT_NAME}FlexBison
	   OUTPUTS ${flexFiles}.flex.c)
	   
	ADD_CUSTOM_COMMAND(
	   DEPENDS ${flexFiles}.y
	   COMMAND ${BISON_EXECUTABLE}
	   ARGS -o"${bisonFiles}.bison.c"
			"${bisonFiles}.y"
	   TARGET ${PROJECT_NAME}FlexBison
	   OUTPUTS ${bisonFiles}.bison.c)

	add_dependencies(${PROJECT_NAME} ${PROJECT_NAME}FlexBison)
		if( MSVC )
		SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)
		SET_PROPERTY(TARGET ${PROJECT_NAME}FlexBison		PROPERTY FOLDER CMakePredefinedTargets)
		endif()
endif()