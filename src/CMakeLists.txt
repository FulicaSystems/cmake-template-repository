set(component src)

configure_file(directories.hpp.in ${CMAKE_BINARY_DIR}/directories.hpp @ONLY)
# configure_file(resource_bank.hpp.in ${CMAKE_BINARY_DIR}/resource_bank.hpp @ONLY)
# configure_file(asset_bank.hpp.in ${CMAKE_BINARY_DIR}/asset_bank.hpp @ONLY)
# configure_file(media_bank.hpp.in ${CMAKE_BINARY_DIR}/media_bank.hpp @ONLY)

add_executable(${component})

target_sources(${component}
    PRIVATE
    main.cpp

    # add client sources and private headers here
    # ...
)

target_link_libraries(${component}
    # add dependencies here
    # ...
)

# build events
# set(RUNTIME_OUTPUT_DIR $<TARGET_FILE_DIR:${component}>)
#
# add_custom_command(TARGET ${component}
#     POST_BUILD
#     COMMAND
# )

# installing build (using cmake --install command)
install(TARGETS ${component})
