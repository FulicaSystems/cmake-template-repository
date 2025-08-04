set(component test_target)

add_executable(${component})

target_sources(${component}
    PRIVATE
    main.cpp
)

# https://cmake.org/cmake/help/book/mastering-cmake/chapter/Testing%20With%20CMake%20and%20CTest.html#how-does-cmake-facilitate-testing
# https://cmake.org/cmake/help/latest/command/add_test.html

add_test(NAME "First test"
    COMMAND ${component}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
# add_test(NAME "Second test"
#     COMMAND ${component}
#     WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
# )
