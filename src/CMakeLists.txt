set(component src)

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
