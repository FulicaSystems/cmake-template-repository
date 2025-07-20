# Dependency manager

# make a dependency available for this cmake project
function(depends)
    set(options

        PACKAGE
        MODULE
        PRECOMPILED
        HEADERONLY

        STATIC # does nothing
        SHARED # default to STATIC
        CONFIGURE_DEPENDS
    )
    set(keywords

        CONFIG
        VERSION

        OUTPUT_TARGET
        DEBUG_SUFFIX
    )
    set(multikeywords

        DIRECTORIES
        FILES
    )
    cmake_parse_arguments(arg_depends
        "${options}"
        "${keywords}"
        "${multikeywords}"
        ${ARGN}
    )

    if (${arg_depends_PACKAGE})
        depends_package("${arg_depends_DIRECTORIES}" "${arg_depends_CONFIG}" "${arg_depends_VERSION}")
    elseif (${arg_depends_MODULE})
        depends_module()
    elseif (${arg_depends_PRECOMPILED})
        depends_precompiled("${arg_depends_SHARED}" "${arg_depends_CONFIGURE_DEPENDS}" "${arg_depends_OUTPUT_TARGET}" "${arg_depends_DIRECTORIES}" "${arg_depends_FILES}" "${arg_depends_DEBUG_SUFFIX}")
    elseif (${arg_depends_HEADERONLY})
        depends_headeronly()
    else()
        message(FATAL_ERROR "A dependency type must be specified [PACKAGE|MODULE|PRECOMPILED|HEADERONLY]")
    endif()
endfunction()

# package based external dependency
# should include a *Config.cmake or *-config.cmake file
#
# Based on nvpro_core2 integration
# https://github.com/nvpro-samples/nvpro_core2
function(depends_package PACKAGE_FOLDER_NAME CONFIG_NAME PACKAGE_VERSION)
    message("\nLooking for ${PACKAGE_FOLDER_NAME} near ${CMAKE_SOURCE_DIR}...")
    find_path(${PACKAGE_FOLDER_NAME}-DIR
        NAMES CMakeLists.txt
        PATHS ${CMAKE_CURRENT_LIST_DIR}/${PACKAGE_FOLDER_NAME}
            ${CMAKE_SOURCE_DIR}/${PACKAGE_FOLDER_NAME}
            ${CMAKE_SOURCE_DIR}/../${PACKAGE_FOLDER_NAME}
            ${CMAKE_SOURCE_DIR}/../../${PACKAGE_FOLDER_NAME}
        REQUIRED
    )
    message("${PACKAGE_FOLDER_NAME}-DIR=${${PACKAGE_FOLDER_NAME}-DIR}")
    
    # TODO : fix condition
    if (${${PACKAGE_FOLDER_NAME}-DIR} EQUAL ${PACKAGE_FOLDER_NAME}-NOTFOUND)
        message("${PACKAGE_FOLDER_NAME} was not found")

        if (CLONE_FROM_URL)
            # TODO
            message("Cloning from ${${PACKAGE_FOLDER_NAME}-URL}...")
        endif()
    else()
        message("${PACKAGE_FOLDER_NAME} was found : ${${PACKAGE_FOLDER_NAME}-DIR}")

        string(TOLOWER ${CONFIG_NAME} CONFIG_NAME_LOWER)
        find_path(${PACKAGE_FOLDER_NAME}_CONFIG
            NAMES ${CONFIG_NAME}Config.cmake
                ${CONFIG_NAME_LOWER}-config.cmake
            PATHS ${${PACKAGE_FOLDER_NAME}-DIR}/build
            REQUIRED
        )

        list(APPEND CMAKE_PREFIX_PATH ${${PACKAGE_FOLDER_NAME}-DIR})
        find_package(${CONFIG_NAME} ${PACKAGE_VERSION} REQUIRED NO_MODULE)
        
        message("${CONFIG_NAME} is ready to link\n")
    endif()

endfunction()

# module based external dependency
function(depends_module)
endfunction()

# precompiled library
# default to STATIC
# look for FOLDER_NAMES in default path and cmake paths if not specified
function(depends_precompiled SHARED CONFIGURE_DEPENDS TARGET_NAME FOLDER_NAMES LIB_FILES DEBUG_SUFFIX)
    list(LENGTH FOLDER_NAMES FOLDER_NAMES_LENGTH)
    if (${FOLDER_NAMES_LENGTH} GREATER 0)
        list(GET FOLDER_NAMES 0 FOLDER_NAME)
        list(GET LIB_FILES 0 LIB_FILE)

        cmake_path(IS_ABSOLUTE FOLDER_NAME IS_ABS)
        if (${IS_ABS})
            message("\nLooking for ${LIB_FILE} in ${FOLDER_NAME}...")
            cmake_path(CONVERT "${FOLDER_NAME}" TO_CMAKE_PATH_LIST FOLDER_NAME NORMALIZE)
            find_path(${FOLDER_NAME}-DIR
                NAMES .
                PATHS ${FOLDER_NAME}
                NO_DEFAULT_PATH
                NO_PACKAGE_ROOT_PATH
                NO_CMAKE_PATH
                NO_CMAKE_ENVIRONMENT_PATH
                NO_SYSTEM_ENVIRONMENT_PATH
                NO_CMAKE_SYSTEM_PATH
                NO_CMAKE_INSTALL_PREFIX
                REQUIRED
            )
        else()
            message("\nLooking for ${LIB_FILE} near ${CMAKE_SOURCE_DIR}...")
            find_path(${FOLDER_NAME}-DIR
                NAMES .
                PATHS ${CMAKE_CURRENT_LIST_DIR}/${FOLDER_NAME}
                    ${CMAKE_SOURCE_DIR}/${FOLDER_NAME}
                    ${CMAKE_SOURCE_DIR}/../${FOLDER_NAME}
                    ${CMAKE_SOURCE_DIR}/../../${FOLDER_NAME}
                NO_DEFAULT_PATH
                NO_PACKAGE_ROOT_PATH
                NO_CMAKE_PATH
                NO_CMAKE_ENVIRONMENT_PATH
                NO_SYSTEM_ENVIRONMENT_PATH
                NO_CMAKE_SYSTEM_PATH
                NO_CMAKE_INSTALL_PREFIX
                REQUIRED
            )
        endif()
    else()
        if (WIN32)
            message("\nLooking for ${LIB_FILE} in default and cmake paths...")
            set(FOLDER_NAME ${TARGET_NAME})
            find_path(${FOLDER_NAME}-DIR
                NAMES ${LIB_FILE}.lib
                REQUIRED
            )
        else()
            message(FATAL_ERROR "No other platforms supported yet")
        endif()
    endif()

    message("${FOLDER_NAME}-DIR=${${FOLDER_NAME}-DIR}")

    # adding a pre compiled static/shared library (interface)
    # https://cmake.org/cmake/help/latest/command/add_library.html#imported-libraries
    if (TARGET ${TARGET_NAME})
        return()
    endif()

    if (NOT ${SHARED})
        add_library(${TARGET_NAME} STATIC IMPORTED GLOBAL)
    else()
        add_library(${TARGET_NAME} SHARED IMPORTED GLOBAL)
    endif()
    set_target_properties(${TARGET_NAME} PROPERTIES
        LINKER_LANGUAGE CXX
    )


    target_include_directories(${TARGET_NAME} INTERFACE ${${FOLDER_NAME}-DIR})

    if (NOT CONFIGURE_DEPENDS)
        if (${FOLDER_NAMES_LENGTH} LESS 2)
            target_link_libraries(${TARGET_NAME} INTERFACE ${${FOLDER_NAME}-DIR})
        else()
            list(GET FOLDER_NAMES 1 SHARED_FOLDER_NAME)
            target_link_libraries(${TARGET_NAME} INTERFACE ${SHARED_FOLDER_NAME})
        endif()
    endif()


    if (WIN32)
        if (NOT ${SHARED})
            set_property(TARGET ${TARGET_NAME}
                APPEND PROPERTY IMPORTED_LOCATION_DEBUG "${${FOLDER_NAME}-DIR}/${LIB_FILE}${DEBUG_SUFFIX}.lib"
            )
            set_property(TARGET ${TARGET_NAME}
                APPEND PROPERTY IMPORTED_LOCATION_RELEASE "${${FOLDER_NAME}-DIR}/${LIB_FILE}.lib"
            )

        else()
            set_property(TARGET ${TARGET_NAME}
                APPEND PROPERTY IMPORTED_IMPLIP_DEBUG "${${FOLDER_NAME}-DIR}/${LIB_FILE}${DEBUG_SUFFIX}.lib"
            )
            set_property(TARGET ${TARGET_NAME}
                APPEND PROPERTY IMPORTED_IMPLIB_RELEASE "${${FOLDER_NAME}-DIR}/${LIB_FILE}.lib"
            )

            # may require changing workspace directory (cwd, pwd) regarding the IDE
            if (${FOLDER_NAMES_LENGTH} EQUAL 2)
                list(LENGTH LIB_FILES LIB_FILES_LENGTH)
                if (${LIB_FILES_LENGTH} LESS 2)
                    message(FATAL_ERROR "Two paths were given but only 1 library names (or 0)")
                endif()

                list(GET FOLDER_NAMES 1 SHARED_FOLDER_NAME)
                list(GET LIB_FILES 1 SHARED_LIB_FILE)

                set_property(TARGET ${TARGET_NAME}
                    APPEND PROPERTY IMPORTED_LOCATION_DEBUG "${SHARED_FOLDER_NAME}/${SHARED_LIB_FILE}${DEBUG_SUFFIX}.dll"
                )
                set_property(TARGET ${TARGET_NAME}
                    APPEND PROPERTY IMPORTED_LOCATION_RELEASE "${SHARED_FOLDER_NAME}/${SHARED_LIB_FILE}.dll"
                )
                
                if (CONFIGURE_DEPENDS)
                    configure_file(${SHARED_FOLDER_NAME}/${SHARED_LIB_FILE}.dll ${CMAKE_BINARY_DIR}/${SHARED_LIB_FILE}.dll COPYONLY)
                endif()
            else()
                message(FATAL_ERROR "Does not support arbitrary lib and dll paths, please specify both paths")

                set_property(TARGET ${TARGET_NAME}
                    APPEND PROPERTY IMPORTED_LOCATION_DEBUG "${${FOLDER_NAME}-DIR}/${LIB_FILE}${DEBUG_SUFFIX}.dll"
                )
                set_property(TARGET ${TARGET_NAME}
                    APPEND PROPERTY IMPORTED_LOCATION_RELEASE "${${FOLDER_NAME}-DIR}/${LIB_FILE}.dll"
                )

                file(GLOB_RECURSE SHARED_LIB_NAME ${${FOLDER_NAME}-DIR} ${LIB_FILE}.dll)
                if (NOT SHARED_LIB_NAME)
                    message(FATAL_ERROR "Failed to find ${LIB_FILE}.dll in ${${FOLDER_NAME}-DIR}")
                endif()

                if (CONFIGURE_DEPENDS)
                    configure_file(${SHARED_LIB_NAME}.dll ${CMAKE_BINARY_DIR}/${LIB_FILE}.dll COPYONLY)
                endif()
            endif()
            
            # for install
            install(FILES ${LIB_FILE}.dll TYPE BIN)

        endif()

        set_property(TARGET ${TARGET_NAME}
            APPEND PROPERTY MAP_IMPORTED_CONFIG_MINSIZEREL Release
        )
        set_property(TARGET ${TARGET_NAME}
            APPEND PROPERTY MAP_IMPORTED_CONFIG_RELWITHDEBINFO Release
        )
        
    else()
        message(FATAL_ERROR "No other platform supported yet")
    endif()

    message("${TARGET_NAME} is ready to be linked as ${TARGET_NAME}\n")

endfunction()

# header only library
function(depends_headeronly)
endfunction()