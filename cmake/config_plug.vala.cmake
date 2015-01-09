
// Generated file: do not modify
// Bundle version: 0.9
//File History:
//    - 0.1 : initial release
//    - 0.2 : refactor to support apps

namespace Build {

    public const string DATADIR = "@DATADIR@";
    public const string PKGDATADIR = "@PKGDATADIR@";
    public const string GETTEXT_PACKAGE = "@GETTEXT_PACKAGE@";

    public const string VERSION = "@ELEM_VERSION@";
    public const string TITLE = "@ELEM_TITLE@";
    public const string BINARY_NAME = "@CMAKE_PROJECT_NAME@";

    // Values: Release or Debug
    public const string BUILD = "@CMAKE_BUILD_TYPE@";

    // Values: personal, hardware, network, system
    public const string PLUG_CATEGORY = "@PLUG_CATEGORY@";

    public string to_string () {
        var result = new StringBuilder () ;
        result.append (" - DATADIR         : %s\n".printf(DATADIR)) ;
        result.append (" - PKGDATADIR      : %s\n".printf(PKGDATADIR)) ;
        result.append (" - GETTEXT_PACKAGE : %s\n".printf(GETTEXT_PACKAGE)) ;
        result.append (" - TITLE           : %s\n".printf(TITLE)) ;
        result.append (" - VERSION         : %s\n".printf(VERSION)) ;
        result.append (" - BINARY_NAME     : %s\n".printf(BINARY_NAME)) ;
        result.append (" - BUILD           : %s\n".printf(BUILD)) ;
        result.append (" - PLUG_CATEGORY   : %s\n".printf(PLUG_CATEGORY)) ;
        return result.str ;
    }
}
