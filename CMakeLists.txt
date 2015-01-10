cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include (Elementary)

set (VALA_VERSION_MIN "0.26")

set (BUILD_TYPE "Release")
#set (DEBIAN_PACKAGE "lib-vala-stracktrace-dev")

build_elementary_cli (
    BINARY_NAME
        error_sigtrap
    TITLE
        "Vala stacktrace sigtrap test"
    VERSION
        "1.0"
    SOURCE_PATH
        samples
    VALA_FILES
        error_sigtrap.vala
    C_OPTIONS
        -rdynamic
    PACKAGES
        vala-stacktrace
)

build_elementary_library (
    BINARY_NAME
        vala-stacktrace
    TITLE
        "Vala stacktrace display"
    VERSION
        "0.9"
    LINKING
        shared
    SOURCE_PATH
        src
    VALA_FILES
        Stacktrace.vala
    PACKAGES
        gee-0.8
        linux
)


# No translations
# build_translations()
