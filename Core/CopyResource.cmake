foreach(v SrcDir DestDir)
  if(NOT DEFINED ${v})
    message(FATAL_ERROR "${v} not defined on command line")
  endif()
endforeach()

file(GLOB_RECURSE
	MY_SHADERS
	${SrcDir}/*.vert
	${SrcDir}/*.frag
	${SrcDir}/*.glsl
	)

message("Copy perfromed from:" ${SrcDir})
message("                 to:" ${DestDir})

foreach(shaderFile ${MY_SHADERS})
	FILE(RELATIVE_PATH relPath ${SrcDir} ${shaderFile})
	configure_file(
		${shaderFile}
		${DestDir}/${relPath} COPYONLY)
endforeach()

	#[[
	configure_file(
	${SrcDir}/${p}
    ${CMAKE_CURRENT_BINARY_DIR}/${p} COPYONLY)

file( GLOB_RECURSE FileRelPath RELATIVE
	"${CMAKE_CURRENT_SOURCE_DIR}/" ${SrcDir}
)
message(${FileRelPath})
	
foreach(p IN LISTS files)
  configure_file(${SrcDir}/${p}
    ${DestDir}/${p} COPYONLY)
endforeach()
]]#