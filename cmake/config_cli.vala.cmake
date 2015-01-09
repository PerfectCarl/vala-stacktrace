
// Generated file: do not modify
// Bundle version: 0.9
//File History:
//    - 0.1 : initial release
//    - 0.2 : members are internal

namespace Build {

    internal const string DATADIR = "@DATADIR@";
    internal const string PKGDATADIR = "@PKGDATADIR@";
    internal const string GETTEXT_PACKAGE = "@GETTEXT_PACKAGE@";

    internal const string VERSION = "@ELEM_VERSION@";
    internal const string TITLE = "@ELEM_TITLE@";
    internal const string BINARY_NAME = "@CMAKE_PROJECT_NAME@";

    // Values: Release or Debug
    internal const string BUILD = "@CMAKE_BUILD_TYPE@";

    internal string to_string () {
        var result = new StringBuilder () ;
        result.append (" - DATADIR         : %s\n".printf(DATADIR)) ;
        result.append (" - PKGDATADIR      : %s\n".printf(PKGDATADIR)) ;
        result.append (" - GETTEXT_PACKAGE : %s\n".printf(GETTEXT_PACKAGE)) ;
        result.append (" - TITLE           : %s\n".printf(TITLE)) ;
        result.append (" - VERSION         : %s\n".printf(VERSION)) ;
        result.append (" - BINARY_NAME     : %s\n".printf(BINARY_NAME)) ;
        result.append (" - BUILD           : %s\n".printf(BUILD)) ;
        return result.str ;
    }
}
