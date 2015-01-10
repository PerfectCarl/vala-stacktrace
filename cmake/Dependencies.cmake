# Bundle version: 0.9
#
# File History:
#    - 0.1 : initial release

if( NOT DIR_ELEMENTARY_CMAKE )
    set(DIR_ELEMENTARY_CMAKE ${CMAKE_CURRENT_LIST_DIR})
endif()

macro (read_dependency_file)
    if( NOT DEPEND_FILE_READ )

        set( list_vala_packages "")
        set( list_pc_packages "")

        set( depend_file "${DIR_ELEMENTARY_CMAKE}/dependencies.list")
        message ("Reading ${depend_file}")

        file(STRINGS ${depend_file} file_content)
        set (line_number 0)

        foreach(line IN LISTS file_content)
            if( line )
                string( STRIP ${line} line)
                string( LENGTH ${line} line_len)
                MATH(EXPR line_number ${line_number}+1)
                #message ("Reading line ${line_number}")

                # Ignore commented line starting with # or empty line
                if( line_len GREATER 0 )
                    string( SUBSTRING ${line} 0 1 line_start)
                    if( NOT line_start STREQUAL "#")
                        #message("line = ${line}")
                        string(REPLACE "->" ";"  line_list ${line})

                        list(GET line_list 0 first_col)
                        string( STRIP ${first_col} first_col)

                        list(GET line_list 1 second_col)
                        string( STRIP ${second_col} second_col)

                        if( second_col STREQUAL "<same>")
                            set (second_col ${first_col})
                        endif()

                        if( second_col STREQUAL "<none>")
                            set (second_col "")
                        endif()

                        list(LENGTH line_list len)
                        set( third_col "")
                        if( len GREATER 2 )
                            list(GET line_list 2 third_col)
                            string( STRIP ${third_col} third_col)
                        endif()

                        list (APPEND list_pc_packages ${first_col})
                        if(third_col)
                            list (APPEND list_vala_packages ${third_col})
                        else()
                            list (APPEND list_vala_packages ${first_col})
                        endif()

                        # message("first = ${first_col}")
                        # message("second = ${second_col}")
                        # message("third = ${third_col}")
                        # message("-")
                    endif()
                endif()
            endif()
        endforeach()
        set(DEPEND_FILE_READ "true")
    endif()
endmacro()

macro (install_dependencies)

endmacro()

macro (get_pc_package vala_package pc_package )
    read_dependency_file()

    list(FIND list_vala_packages ${vala_package} index)

    if( index GREATER -1 )
        list(GET list_pc_packages ${index} pc_package)
    endif()
    if( NOT pc_package)
        set( pc_package ${vala_package} )
    endif()
endmacro()
