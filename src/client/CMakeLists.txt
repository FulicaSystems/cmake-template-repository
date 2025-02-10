set(component client)

add_library(${component} STATIC "")

target_sources(${component}
    PRIVATE
    # add client sources and private headers here
    # ...
)

target_link_libraries(${component}
    # add dependencies here
    # ...
)