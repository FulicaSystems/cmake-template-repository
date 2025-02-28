set(component internal)

add_library(${component} STATIC "")
add_library(MyComponentAlias ALIAS ${component})

set_property(TARGET ${component}
    PROPERTY PUBLIC_HEADER
    # add public headers here
    # ...
)

target_sources(${component}
    PRIVATE
    # add sources and private headers here
    # ...
)

target_link_libraries(${component}
    # add dependencies here
    # ...
)

# add_subdirectory(...)

target_include_directories(${component} PRIVATE "${CMAKE_CURRENT_LIST_DIR}")
target_include_directories(${component} PUBLIC "${CMAKE_CURRENT_LIST_DIR}/..")

# installing build (using cmake --install command)
install(TARGETS ${component})
# installing the include files
install(
    DIRECTORY internal/
    DESTINATION include
    FILES_MATCHING
    PATTERN *.h
    PATTERN *.hpp
    PATTERN *.inl
)
