# CMake version
cmake_minimum_required(VERSION 3.21)

# C++ standard version
set(CMAKE_CXX_STANDARD 20)

# updating git submodules (external libraries)
message(STATUS "Updating submodules...")
execute_process(COMMAND git submodule update --init --recursive
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE GIT_RESULT
)
if(NOT GIT_RESULT EQUAL "0")
    message(FATAL_ERROR "Failed to update submodules : ${GIT_RESULT}")
endif()

set(PROJECT_NAME project_name)

# initiating project given its name
project(${PROJECT_NAME})

add_subdirectory(externals)
add_subdirectory(internal)
add_subdirectory(lib)
add_subdirectory(src)
