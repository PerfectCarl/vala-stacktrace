# Bundle version: 0.9
#
# File History:
#    - 0.1 : initial release
#    - 0.2 : support schemas
#    - 0.3 : support app
#    - 0.4 : misc fixes
#    - 0.5 : support shared libraries
#    - 0.6 : support cli apps. Support C_OPTIONS

# TODO * fix po file generation
# . test libs/apps/cli with fo files
# TODO * deal with thread library
# TODO handle PREFIX
# TODO Deal with build type
# TODO fix run-passwd and other vapi related cases (HARDCODED)
# TODO compute .h folder from .c paths (ASSUMED)
#
# TODO is SOURCE_PATH required?
# TODO install desktop icons and other data files
# TODO generate debian files?
# TODO add VALA_DEFINES
# TODO force the people to have a data/${target}.desktop and install it
# TODO PKGDATADIR and DATADIR always needed?
# TODO include ${CMAKE_CURRENT_SOURCE_DIR}/vapi/ to vapidir

find_package (PkgConfig)

include (ParseArguments)
include (ValaPrecompile)
include (Translations)
include (GNUInstallDirs)
include (GSettings)

# Comment this out to enable C compiler warnings
add_definitions (-w)

if( NOT DIR_ELEMENTARY_CMAKE )
    set(DIR_ELEMENTARY_CMAKE ${CMAKE_CURRENT_LIST_DIR})
endif()

set (SOURCE_PATHS "")

#project(elementary_build)

macro(build_elementary_plug)
    parse_arguments(ARGS "BINARY_NAME;TITLE;VERSION;PLUG_CATEGORY;SOURCE_PATH;VALA_FILES;C_FILES;PACKAGES;C_DEFINES;SCHEMA;VALA_OPTIONS;C_OPTIONS" "" ${ARGN})

    if( NOT ARGS_PLUG_CATEGORY)
        message( FATAL_ERROR "You must specify a PLUG_CATEGORY: personal, hardware, network or system.")
    endif()

    set (DATADIR "${CMAKE_INSTALL_FULL_LIBDIR}/switchboard")
    set (PKGDATADIR "${DATADIR}/${ARGS_PLUG_CATEGORY}/${ARGS_BINARY_NAME}")
    set (GETTEXT_PACKAGE "${ARGS_BINARY_NAME}-plug")

    prepare_elementary (
        BINARY_NAME
            ${ARGS_BINARY_NAME}
        TITLE
            ${ARGS_TITLE}
        VERSION
            ${ARGS_VERSION}
        SOURCE_PATH
            ${ARGS_SOURCE_PATH}
        VALA_FILES
            ${ARGS_VALA_FILES}
        C_FILES
            ${ARGS_C_FILES}
        C_DEFINES
            ${ARGS_C_DEFINES}
        PACKAGES
            gtk+-3.0
            switchboard-2.0
            granite
            ${ARGS_PACKAGES}
        SCHEMA
             ${ARGS_SCHEMA}
        VALA_OPTIONS
             ${ARGS_VALA_OPTIONS}
        CONFIG_NAME
            config_plug.vala.cmake
        C_OPTIONS
             ${ARGS_C_OPTIONS}
    )

    add_library (${ARGS_BINARY_NAME} MODULE ${VALA_C} ${C_FILES})
    target_link_libraries (${ARGS_BINARY_NAME} ${DEPS_LIBRARIES})

    install_elementary_plug (${ARGS_BINARY_NAME})
endmacro()

macro(install_elementary_plug ELEM_NAME)
    install (TARGETS ${ELEM_NAME} DESTINATION ${PKGDATADIR})
endmacro()

macro(build_elementary_app)
    parse_arguments(ARGS "BINARY_NAME;TITLE;VERSION;SOURCE_PATH;VALA_FILES;C_FILES;PACKAGES;C_DEFINES;SCHEMA;VALA_OPTIONS;C_OPTIONS" "" ${ARGN})

    set (DATADIR "")
    set (PKGDATADIR "")
    set (GETTEXT_PACKAGE "")

    prepare_elementary (
        BINARY_NAME
            ${ARGS_BINARY_NAME}
        TITLE
            ${ARGS_TITLE}
        VERSION
            ${ARGS_VERSION}
        SOURCE_PATH
            ${ARGS_SOURCE_PATH}
        VALA_FILES
            ${ARGS_VALA_FILES}
        C_FILES
            ${ARGS_C_FILES}
        C_DEFINES
            ${ARGS_C_DEFINES}
        PACKAGES
            ${ARGS_PACKAGES}
        SCHEMA
             ${ARGS_SCHEMA}
        VALA_OPTIONS
             ${ARGS_VALA_OPTIONS}
        CONFIG_NAME
            config_app.vala.cmake
        C_OPTIONS
             ${ARGS_C_OPTIONS}
    )

    add_executable (${ARGS_BINARY_NAME} ${VALA_C} ${C_FILES})
    target_link_libraries (${ARGS_BINARY_NAME} ${DEPS_LIBRARIES})

    install_elementary_app (${ARGS_BINARY_NAME})
endmacro()

macro(install_elementary_app ELEM_NAME)
    #install (TARGETS ${CMAKE_PROJECT_NAME} DESTINATION bin)
    install (TARGETS ${ELEM_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
endmacro()

macro(build_elementary_cli)
    parse_arguments(ARGS "BINARY_NAME;TITLE;VERSION;SOURCE_PATH;VALA_FILES;C_FILES;PACKAGES;C_DEFINES;SCHEMA;VALA_OPTIONS;C_OPTIONS" "" ${ARGN})

    set (DATADIR "")
    set (PKGDATADIR "")
    set (GETTEXT_PACKAGE "")

    prepare_elementary (
        BINARY_NAME
            ${ARGS_BINARY_NAME}
        TITLE
            ${ARGS_TITLE}
        VERSION
            ${ARGS_VERSION}
        SOURCE_PATH
            ${ARGS_SOURCE_PATH}
        VALA_FILES
            ${ARGS_VALA_FILES}
        C_FILES
            ${ARGS_C_FILES}
        C_DEFINES
            ${ARGS_C_DEFINES}
        PACKAGES
            ${ARGS_PACKAGES}
        SCHEMA
             ${ARGS_SCHEMA}
        VALA_OPTIONS
             ${ARGS_VALA_OPTIONS}
        CONFIG_NAME
            config_cli.vala.cmake
        C_OPTIONS
             ${ARGS_C_OPTIONS}
    )

    add_executable (${ARGS_BINARY_NAME} ${VALA_C} ${C_FILES})
    target_link_libraries (${ARGS_BINARY_NAME} ${DEPS_LIBRARIES})

    install_elementary_cli (${ARGS_BINARY_NAME})
endmacro()

macro(install_elementary_cli ELEM_NAME)
    #install (TARGETS ${CMAKE_PROJECT_NAME} DESTINATION bin)
    #install (TARGETS ${ELEM_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
endmacro()

macro(build_elementary_library)
    parse_arguments(ARGS "BINARY_NAME;TITLE;VERSION;SOVERSION;LINKING;SOURCE_PATH;VALA_FILES;C_FILES;PACKAGES;C_DEFINES;SCHEMA;VALA_OPTIONS;C_OPTIONS" "" ${ARGN})

    if( NOT ARGS_LINKING)
        message( FATAL_ERROR "You must specify a LINKING: static or shared.")
    endif()

    if( NOT ARGS_LINKING STREQUAL "shared" AND NOT ARGS_LINKING STREQUAL "static")
        message( FATAL_ERROR "The value LINKING must be either static or shared.")
    endif()

    set (DATADIR "")
    set (PKGDATADIR "")
    set (GETTEXT_PACKAGE "")

    # configure_file (${CMAKE_SOURCE_DIR}/core/${CORE_LIBRARY_NAME}.pc.cmake ${CMAKE_BINARY_DIR}/core/${CORE_LIBRARY_NAME}.pc)
    prepare_elementary (
        BINARY_NAME
            ${ARGS_BINARY_NAME}
        TITLE
            ${ARGS_TITLE}
        VERSION
            ${ARGS_VERSION}
        SOURCE_PATH
            ${ARGS_SOURCE_PATH}
        VALA_FILES
            ${ARGS_VALA_FILES}
        C_FILES
            ${ARGS_C_FILES}
        C_DEFINES
            ${ARGS_C_DEFINES}
        PACKAGES
            ${ARGS_PACKAGES}
        SCHEMA
             ${ARGS_SCHEMA}
        VALA_OPTIONS
             ${ARGS_VALA_OPTIONS}
        CONFIG_NAME
            config_lib.vala.cmake
        LINKING
            ${ARGS_LINKING}
        C_OPTIONS
             ${ARGS_C_OPTIONS}
    )

    # Set for the variables substitution in the pc file
    set (DOLLAR "$")
    # TODO fix the output path
    configure_file (${DIR_ELEMENTARY_CMAKE}/lib.pc.cmake ${CMAKE_BINARY_DIR}/${ARGS_BINARY_NAME}.pc)
    configure_file (${DIR_ELEMENTARY_CMAKE}/lib.deps.cmake ${CMAKE_BINARY_DIR}/${ARGS_BINARY_NAME}.deps)

    if( ARGS_LINKING STREQUAL "static")
        add_library (${ARGS_BINARY_NAME} STATIC ${VALA_C} ${C_FILES})
    else()
        add_library (${ARGS_BINARY_NAME} SHARED ${VALA_C} ${C_FILES})
        if( NOT ARGS_SOVERSION)
            set( ARGS_SOVERSION "0")
        endif()

        set_target_properties (${ARGS_BINARY_NAME} PROPERTIES
            OUTPUT_NAME ${ARGS_BINARY_NAME}
            VERSION ${ARGS_VERSION}
            SOVERSION ${ARGS_SOVERSION}
        )
    endif()

    target_link_libraries (${ARGS_BINARY_NAME} ${DEPS_LIBRARIES})

    install_elementary_library (${ARGS_BINARY_NAME} ${ARGS_LINKING})
endmacro()

macro(install_elementary_library ELEM_NAME BUILD_TYPE)
    if (${BUILD_TYPE} STREQUAL "shared" )
        install (TARGETS ${ELEM_NAME} DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR})
        # Install lib stuffs
        install (FILES ${CMAKE_BINARY_DIR}/${ELEM_NAME}.pc              DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig/)
        install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${ELEM_NAME}.vapi    DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/vala/vapi/)
        install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${ELEM_NAME}.deps    DESTINATION ${CMAKE_INSTALL_FULL_DATAROOTDIR}/vala/vapi/)
        install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${ELEM_NAME}.h       DESTINATION ${CMAKE_INSTALL_FULL_INCLUDEDIR}/${ELEM_NAME}/)
    endif ()

endmacro()

macro(build_translations)
    # Add po folder if present
    # TODO fix if no po folder is found
    # TODO recurse folders??
    #if( NOT DISABLE_PO)
        set( PO_FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/po")
        if(EXISTS ${PO_FOLDER} )
            add_translations_directory (${PO_FOLDER} ${GETTEXT_PACKAGE})
            # TODO remove src here
            message ("SOURCE PATHS: ${SOURCE_PATHS}")
            add_translations_catalog (${PO_FOLDER} ${GETTEXT_PACKAGE} ${SOURCE_PATHS})
            add_definitions (-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
        endif ()
        # PO files are only computed once
        #set (DISABLE_PO "true")
    #endif()
endmacro()

macro(prepare_elementary)
    parse_arguments(ARGS "BINARY_NAME;TITLE;VERSION;SOURCE_PATH;VALA_FILES;C_FILES;PACKAGES;C_DEFINES;SCHEMA;VALA_OPTIONS;CONFIG_NAME;LINKING;C_OPTIONS" "" ${ARGN})

    if(ARGS_BINARY_NAME)
        project (${ARGS_BINARY_NAME})
    else()
        message( FATAL_ERROR "You must specify a BINARY_NAME")
    endif()

    # TODO handle the case where the source is not precised
    if(ARGS_SOURCE_PATH)
        list(APPEND SOURCE_PATHS ${ARGS_SOURCE_PATH})
        list(REMOVE_DUPLICATES SOURCE_PATHS)
    else()
        message ("Error, you must provide a SOURCE_PATH argument")
    endif()

    #add_subdirectory (${ARGS_SOURCE_PATH} ${CMAKE_BINARY_DIR}/${ARGS_BINARY_NAME})

    if(ARGS_VERSION)
        set (ELEM_VERSION ${ARGS_VERSION})
    else()
        message( FATAL_ERROR "You must specify a VERSION. Example: 1.0")
    endif()

    if(ARGS_TITLE)
        set (ELEM_TITLE ${ARGS_TITLE})
    else()
        message( FATAL_ERROR "You must specify a TITLE. Example: \"My application\"")
    endif()

    # Add schema
    if(ARGS_SCHEMA)
        add_schema (${ARGS_SCHEMA})
    endif()

    # Checking vala version
    if(NOT VALA_VERSION_MIN)
        message ("Using Vala 0.26.0 as minimum")
        SET(VALA_VERSION_MIN "0.26.0" )
    endif()
    find_package (Vala REQUIRED)
    include (ValaVersion)
    ensure_vala_version (VALA_VERSION_MIN MINIMUM)

    # Add the source path to the vala files
    set (VALA_FILES "")
    if( ARGS_VALA_FILES AND ARGS_SOURCE_PATH)
        foreach(source_file ${ARGS_VALA_FILES})
           list(APPEND VALA_FILES ${ARGS_SOURCE_PATH}/${source_file})
        endforeach()
    endif()

    # Add the source path to the c files and add the path
    # to the matching .h files
    set (C_FILES "")
    if( ARGS_C_FILES AND ARGS_SOURCE_PATH)
        foreach(source_file ${ARGS_C_FILES})
           list(APPEND C_FILES ${ARGS_SOURCE_PATH}/${source_file})
        endforeach()
        # TODO: extract the include dirs from the folder above
        include_directories (${ARGS_SOURCE_PATH})
    endif()


    # Check packages that are not provided in the vapi folder
    set(checked_packages "")
    set(vapi_packages "")

    # Add the C defines
    foreach(def ${ARGS_C_DEFINES})
        add_definitions ("-D${def}")
    endforeach()

    # Add the C options
    foreach(opt ${ARGS_C_OPTIONS})
        add_definitions ("${opt}")
    endforeach()

    # Handle the packges
    set (PACKAGES "")
    set (COMPLETE_DIST_PACKAGES "")
    set (ELEM_DEPS_PACKAGES "")
    foreach(pkg ${ARGS_PACKAGES})
        # Deal with special UGLY cases here
        if( pkg STREQUAL "AccountsService-1.0")
            SET (pkg "accountsservice")
        endif()

        #if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/vapi/${pkg}.vapi" OR pkg STREQUAL "posix")
        # TODO deal with run-passwd
        if(pkg STREQUAL "posix" OR pkg STREQUAL "run-passwd" OR pkg STREQUAL "linux")
            # message ("Ignoring checking for ${pkg}")
            list(APPEND vapi_packages "${pkg}")
        else()
            # message ("Adding checked pkg ${pkg}")
            list(APPEND checked_packages "${pkg}")
        endif()

        # Posix and linux are vala only packages without
        # c libraries -> they should be excluded from the pc and
        # deps files
        if(NOT pkg STREQUAL "run-passwd" AND NOT pkg STREQUAL "linux" AND NOT pkg STREQUAL "posix")
            set(COMPLETE_DIST_PACKAGES " ${COMPLETE_DIST_PACKAGES} ${pkg}")
            set(ELEM_DEPS_PACKAGES  "${ELEM_DEPS_PACKAGES}${pkg}\n")
        endif()

        # TODO Handle threading better with the options etc
        # TODO test this
        if( NOT pkg STREQUAL "gthread-2.0")
            set(PACKAGES ${PACKAGES} ${pkg})
        endif()
    endforeach()

    if( checked_packages )
        pkg_check_modules (DEPS REQUIRED ${checked_packages})
        add_definitions (${DEPS_CFLAGS})
        link_libraries (${DEPS_LIBRARIES})
        link_directories (${DEPS_LIBRARY_DIRS})
    endif()
    # Add vapi folder if present

    # Generate config file
    if( ARGS_CONFIG_NAME)
        set (CONFIG_FILE /tmp/config-${ARGS_BINARY_NAME}.vala)
        configure_file (${DIR_ELEMENTARY_CMAKE}/${ARGS_CONFIG_NAME} ${CONFIG_FILE})
    endif()

    if (ARGS_LINKING)
        message ("ONE : ${ARGS_BINARY_NAME}")
        set( LIBRARY_NAME  ${ARGS_BINARY_NAME})

        # Precompile vala files
        vala_precompile (VALA_C ${ARGS_BINARY_NAME}
            ${VALA_FILES}
            ${CONFIG_FILE}
        PACKAGES
            ${PACKAGES}
        OPTIONS
            # TODO : deprecated ??
            --thread
            # TODO
            --vapidir=${CMAKE_BINARY_DIR}
            ${ARGS_VALA_OPTIONS}
            --vapi-comments
        # For libraries
        GENERATE_VAPI
            ${LIBRARY_NAME}
        GENERATE_HEADER
            ${LIBRARY_NAME}
        )
        set( ELEM_VAPI_DIR ${CMAKE_BINARY_DIR})
        message( "ELEM_VAPI_DIR ${ELEM_VAPI_DIR}")

    else()
        message ("TWO ${ARGS_BINARY_NAME}")
        # Precompile vala files
        vala_precompile (VALA_C ${ARGS_BINARY_NAME}
            ${VALA_FILES}
            ${CONFIG_FILE}
        PACKAGES
            ${PACKAGES}
        OPTIONS
            # TODO : deprecated ??
            --thread
            # TODO
            --vapidir=${CMAKE_BINARY_DIR}
            ${ARGS_VALA_OPTIONS}

        )
    endif()



    # Build files ${ARGS_SOURCE_PATH}
    include_directories (${CMAKE_CURRENT_SOURCE_DIR})

endmacro()

