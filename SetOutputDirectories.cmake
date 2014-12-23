SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/Binaries CACHE PATH "Single Directory for all executables." )
SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}/Binaries CACHE PATH "Single Directory for all executables." )
SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_SOURCE_DIR}/Binaries CACHE PATH "Single Directory for all executables." )
SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${CMAKE_SOURCE_DIR}/Binaries CACHE PATH "Single Directory for all executables." )
SET( CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_SOURCE_DIR}/Binaries CACHE PATH "Single Directory for all executables." )

SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/Binaries/Libraries CACHE PATH "Single Directory for all static libraries." )
SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}/Binaries/Libraries/Release CACHE PATH "Single Directory for all static libraries." )
SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${CMAKE_SOURCE_DIR}/Binaries/Libraries/Debug CACHE PATH "Single Directory for all static libraries." )
SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL ${CMAKE_SOURCE_DIR}/Binaries/Libraries/MinSizeRel CACHE PATH "Single Directory for all static libraries." )
SET( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO ${CMAKE_SOURCE_DIR}/Binaries/Libraries/RelWithDebInfo CACHE PATH "Single Directory for all static libraries." )

SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/Binaries/Libraries CACHE PATH "Single Directory for all static libraries.")
SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_SOURCE_DIR}/Binaries/Libraries/Release CACHE PATH "Single Directory for all static libraries.")
SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}/Binaries/Libraries/Debug CACHE PATH "Single Directory for all static libraries.")
SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG ${CMAKE_SOURCE_DIR}/Binaries/Libraries/MinSizeRel CACHE PATH "Single Directory for all static libraries.")
SET( CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE ${CMAKE_SOURCE_DIR}/Binaries/Libraries/RelWithDebInfo CACHE PATH "Single Directory for all static libraries.")

SET( CMAKE_PDB_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/Binaries/Libraries CACHE PATH "Single Directory for all static libraries." )
SET( CMAKE_DEBUG_POSTFIX "-d" )
SET( CMAKE_INCLUDE_CURRENT_DIR ON )

file(MAKE_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
file(MAKE_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})

if(WIN32)
add_definitions( "-DPLATFORM_WINDOWS" )
endif(WIN32)

if(MACOS)
add_definitions( "-DPLATFORM_MACOS" )
endif(MACOS)