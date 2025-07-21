# CMake version
cmake_minimum_required(VERSION 3.21)

# C++ standard version
set(CMAKE_CXX_STANDARD 20)

set(PROJECT_NAME project_name)

# initiating project given its name
project(${PROJECT_NAME})

option(PROJECT_BUILD_TESTS "Build tests" ON)

include(cmake/dependency.cmake)

add_subdirectory(externals)
add_subdirectory(internal)
add_subdirectory(lib)

if (PROJECT_BUILD_TESTS)
    include(CTest)
    enable_testing()
    add_subdirectory(test)
endif()

add_subdirectory(src)
