# FindCameraSuite.cmake
#
# Finds the camerasuite library
#
# This will define the following variables
#
#    CAMERASUITE_FOUND
#    CAMERASUITE_INCLUDE_DIRS
#    CAMERASUITE_LIBRARY
#
# Author: FRAMOS

IF(UNIX)
    IF(NOT DEFINED CONDA_PREFIX)
        SET(CONDA_PREFIX "/home/smartrobotics/workspaces/framos_dclaes/env")
    ENDIF ()

    FIND_PATH(CAMERASUITE_VERSION_FILE
         smcs/Version.h
            PATHS ${CONDA_PREFIX}/include/framos/camerasuite
            NO_CACHE

    )
    #SET(CAMERA_SUITE_VERSIONS_FILE "/home/daniel/workspaces/framos/env/include/framos/camerasuite/smcs/Version.h")

    FIND_PATH(CAMERASUITE_INCLUDE_DIRS
        NAME smcs_cpp/CameraSDK.h
            PATHS ${CONDA_PREFIX}/include/framos/camerasuite
            NO_CACHE
    )

    #SET(CAMERASUITE_INCLUDE_DIRS "/home/daniel/workspaces/framos/env/include/framos/camerasuite/smcs_cpp/CameraSDK.h")


    #FIND_PATH(CAMERASUITE_EXAMPLE_DIR
    #    NAME cpp/CMakeLists.txt
    #    HINTS $ENV{CAMERA_SUITE_SRC_PATH}/Examples
    #)
    
    FIND_LIBRARY(CAMERASUITE_LIBRARY
        NAME libCameraSuite.so
        PATHS ${CONDA_PREFIX}/lib/framos/camerasuite
        PATH_SUFFIXES $ENV{CAMERA_SUITE_TARGET_SYSTEM}
            NO_CACHE
    )
    
    #workaround for building applications with CameraSuite dependency 
    #without the -Wl,--unresolved-symbols=ignore-in-shared-libs flag
    #TODO overhaul CameraSuite CMake package with proper target exporting
    IF ( "$ENV{CAMERA_SUITE_TARGET_SYSTEM}" STREQUAL "Linux64_ARM" )
        SET(CAMERASUITE_LIBRARY ${CAMERASUITE_LIBRARY} "-Wl,-rpath-link,${CONDA_PREFIX}/lib/framos/camerasuite/local/Linux64_ARM")
    ELSEIF ( "$ENV{CAMERA_SUITE_TARGET_SYSTEM}" STREQUAL "Linux32_ARM" )
        SET(CAMERASUITE_LIBRARY ${CAMERASUITE_LIBRARY} "-Wl,-rpath-link,${CONDA_PREFIX}/lib/framos/camerasuite/Linux32_ARMhf")
    ELSE()
        SET(CAMERASUITE_LIBRARY ${CAMERASUITE_LIBRARY} "-Wl,-rpath-link,${CONDA_PREFIX}/lib/framos/camerasuite/local")
    ENDIF()
    
ENDIF(UNIX)

IF(WIN32)    
    FIND_PATH(CAMERASUITE_VERSION_FILE
        NAME smcs/Version.h
        HINTS $ENV{CAMERA_SUITE_PATH}/include
    )
    
    FIND_PATH(CAMERASUITE_INCLUDE_DIRS
        NAME smcs_cpp/CameraSDK.h
        HINTS $ENV{CAMERA_SUITE_PATH}/include
    )
    
    FIND_PATH(CAMERASUITE_EXAMPLE_DIR
        NAME cpp/CMakeLists.txt
        HINTS $ENV{CAMERA_SUITE_PATH}/examples
    )
    
    FIND_LIBRARY(CAMERASUITE_LIBRARY
        NAME CameraSuite.lib
        HINTS $ENV{CAMERA_SUITE_PATH}
        PATH_SUFFIXES "lib"
    )
ENDIF(WIN32)

IF(DEFINED CAMERASUITE_VERSION_FILE)
    FILE(READ "${CAMERASUITE_VERSION_FILE}/smcs/Version.h" VER_FILE)
    STRING(REGEX MATCH "CAMERASUITESDK_VERSION_NUM([ |\t]+)([0-9]+,)+" CS_VERSION_LINE ${VER_FILE})
    STRING(REGEX MATCH "([0-9]+,)+" CS_VERSION_NUMBERS ${CS_VERSION_LINE})
    STRING(REGEX MATCH "[0-9]+" CS_VERSION_MAJOR ${CS_VERSION_NUMBERS})
    STRING(REGEX MATCH "(,[0-9]+,[0-9]+)" CS_VERSION_WITHOUT_MAJOR ${CS_VERSION_NUMBERS})
    STRING(REGEX MATCH "[0-9]+" CS_VERSION_MINOR ${CS_VERSION_WITHOUT_MAJOR})
    STRING(REGEX MATCH "(,[0-9]+)$" CS_VERSION_WITHOUT_MINOR ${CS_VERSION_WITHOUT_MAJOR})
    STRING(REGEX MATCH "[0-9]+" CS_VERSION_PATCH ${CS_VERSION_WITHOUT_MINOR})
    
    SET(CAMERASUITE_VERSION_STRING ${CS_VERSION_MAJOR}.${CS_VERSION_MINOR}.${CS_VERSION_PATCH})
    UNSET(VER_FILE)
    UNSET(CS_VERSION_LINE)
    UNSET(CS_VERSION_NUMBERS)
    UNSET(CS_VERSION_MAJOR)
    UNSET(CS_VERSION_MINOR)
    UNSET(CS_VERSION_PATCH)
    UNSET(CS_VERSION_WITHOUT_MAJOR)
    UNSET(CS_VERSION_WITHOUT_MINOR)
    UNSET(CAMERASUITE_VERSION_FILE)
ENDIF()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CameraSuite
                                  REQUIRED_VARS CAMERASUITE_LIBRARY CAMERASUITE_INCLUDE_DIRS
                                  VERSION_VAR CAMERASUITE_VERSION_STRING
)
