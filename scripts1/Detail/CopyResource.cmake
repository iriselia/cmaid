foreach(v SrcDirs DestDir)
  if(NOT DEFINED ${v})
    message(FATAL_ERROR "${v} not defined on command line")
  endif()
endforeach()
string(REPLACE " " ";" SrcDirs "${SrcDirs}")

foreach(SrcDir ${SrcDirs})
	
	file(GLOB_RECURSE
		MY_SHADERS
		${SrcDir}/*.vert
		${SrcDir}/*.frag
		${SrcDir}/*.glsl
	)

	# Copy shaders
	foreach(shaderFile ${MY_SHADERS})
		FILE(RELATIVE_PATH relPath ${SrcDir} ${shaderFile})
		configure_file(
			${shaderFile}
			${DestDir}/${relPath} COPYONLY)
	endforeach()

	file(GLOB_RECURSE MY_CONFIG_FILES ${SrcDir}/*.ini)

	# Copy Config files
	foreach(configFile ${MY_CONFIG_FILES})
		FILE(RELATIVE_PATH relPath ${SrcDir} ${configFile})
		string(REPLACE "/" ";" relPathList "${relPath}")
		list(REMOVE_AT relPathList 0)
		#get_filename_component(fileName ${configFile} NAME)
		string(REPLACE ";" "/" relPath "${relPathList}")
		
		configure_file(
			${configFile}
			${DestDir}/${relPath} COPYONLY)
	endforeach()
endforeach()


message("Copying resource files to the binary output directory...")
#message("Copy perfromed from:" ${SrcDir})
#message("                 to:" ${DestDir})