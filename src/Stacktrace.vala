
public class Stacktrace {

    public class Frame
    {
        public string address  { get; private set; default = "" ; }

        public string line { get; private set; default = "" ; }

        public string line_number { get; private set; default = "" ; }

        public string file_path { get; private set; default = "" ; }

        public string file_short_path { get; private set; default = "" ; }

        public string function { get; private set; default = "" ; }

        public Frame( string address, string line, string function, string file_path, string file_short_path )
        {
            this._address = address;
            this._line = line;

            this._file_path = file_path;
            this._file_short_path = file_short_path;
            this._function = function ;
            this.line_number = extract_line (line);
        }

        public string to_string ()
        {
            var result = line;
            if( result == "" )
                result = " C library at address [" + address + "]";
            return result +  " [" + address + "]";
        }
    }


    public Gee.ArrayList<Frame> _frames = new Gee.ArrayList<Frame>();

    private  Frame first_vala = null ;

    private int max_file_name_length = 0 ;

    private int max_line_number_length = 0 ;

    public Gee.ArrayList<Frame> frames {
        get
        {
            return _frames;
        }
    }

    public Stacktrace()
    {
        create_stacktrace ();
    }

    private string get_string (char* strings, int i)
    {
        var result = "";
        while (strings[i] != 0) {
            char c = strings[i];
            result += "%c".printf (c);
            i++;
        }
        return result;
    }

    private string get_module_name ()
    {
        return "./samples/sample1" ;
    }

    private string extract_short_file_path (string file_path)
    {
        var path = "/home/cran/Projects/vala-stacktrace" ;
        var i = file_path.index_of( path ) ;
        if( i>=0 )
            return file_path.substring ( path.length, file_path.length - path.length ) ;
        return file_path ;
    }

    private void create_stacktrace () {
        int frame_count = 100;
        int skipped_frames_count = 4;

        void*[] array = new void*[frame_count];

        _frames.clear ();
        first_vala = null ;
        max_file_name_length = 0 ;

        int size = Linux.backtrace (array, frame_count);
        Linux.backtrace_symbols_fd (array, size, Posix.STDERR_FILENO);
        stdout.printf ("\n\n");
        # if VALA_0_26
        var strings = Linux.Backtrace.symbols ( array, size );
        # else
            unowned string[] strings = Linux.backtrace_symbols (array, size);
        // Needed because of some weird bug
        strings.length = size;
        # endif

        int[] addresses = (int[])array;
        string module = get_module_name () ;
        // First ones are the handler
        for( int i = skipped_frames_count; i < size; i++ )
        {
            //var str = strings[i] ;
            int address = addresses[i];
            string str = strings[i];

            string a = "%#08x".printf ( address );
            string addr = extract_address (str);
            string file_line = get_line ( module, addr );
            if( file_line == "??:0" || file_line == "??:?")
                file_line = "";
            string func = extract_function_name (str);

            string file_path  = "" ;
            string short_file_path = "" ;
            string l = "" ;
            if( file_line != "" )
            {
                file_path = extract_file_path (file_line);
                short_file_path  = extract_short_file_path (file_path) ;
                l = extract_line (file_line);
            }
            else
                file_path = extract_file_path_from( str) ;
            stdout.printf ("Building %d \n  . addr: [%s]\n  . ad_ : [%s]\n  . line: '%s'\n  . str : '%s'\n  . func: '%s'\n  . file: '%s'\n  . line: '%s'\n",
                i, addr, a, file_line, str, func, file_path, l);

            var frame = new Frame ( a, file_line, func, file_path, short_file_path  );

            if( first_vala == null && file_path.has_suffix(".vala"))
                first_vala = frame ;


            if( short_file_path.length > max_file_name_length )
                max_file_name_length = short_file_path.length ;
            if( l.length > max_line_number_length )
                max_line_number_length = l.length ;
            _frames.add (frame);
        }
    }

    private string extract_function_name ( string line )
    {
        if( line == "" )
            return "";
        var start = line.index_of ( "(");
        if( start>=0 )
        {
            var end =  line.index_of ( "+", start);
            if( end >= 0 )
            {
                var result = line.substring ( start + 1, end - start - 1 );
                return result;
            }
        }
        return "";
    }

    private string extract_file_path_from( string str)
    {
        if( str =="" )
            return "" ;
        var start = str.index_of ( "(");
        if( start >= 0 )
        {
            return str.substring (0, start ) ;
        }
        return str ;
    }

    private string extract_file_path ( string line )
    {
        if( line == "" )
            return "";
        var start = line.index_of ( ":");
        if( start>=0 )
        {
            var result = line.substring (0, start );
            return result;
        }
        return "";
    }

    public static string extract_line ( string line )
    {
        if( line == "" )
            return "";
        var start = line.index_of ( ":");
        if( start>=0 )
        {
            var result = line.substring (start+1, line.length-start-1 );
            return result;
        }
        return "";
    }

    private string extract_address ( string line )
    {
        if( line == "" )
            return "";
        var start = line.index_of ( "[");
        if( start>=0 )
        {
            var end =  line.index_of ( "]", start);
            if( end >= 0 )
            {
                var result = line.substring ( start + 1, end - start - 1 );
                return result;
            }
        }
        return "";
    }

    private string execute_command_sync_get_output (string cmd)
    {
        try {
            int exitCode;
            string std_out;
            Process.spawn_command_line_sync (cmd, out std_out, null, out exitCode);
            return std_out;
        }
        catch (Error e){
            error (e.message);
            return "error " + e.message;
        }
    }

    // Poor's man demangler. libunwind is another dep
    // module : app
    // address : 0x007f80
    // output : /home/cran/Projects/noise/noise-perf-instant-search/tests/errors.vala:87
    string get_line ( string module, string address ) {
        var cmd = "addr2line -e ./%s %s".printf ( module, address);
        var result = execute_command_sync_get_output ( cmd );
        result = result.replace ("\n", "");
        return result;
    }

    private string get_signal_name()
    {
        return "SIGABRT" ;
    }

    private string get_printable_function (Frame frame)
    {
        if( frame.function == "" )
            return "<unknown>" ;

        return "'" + frame.function + "'" ;
    }

    private string get_printable_line_number( Frame frame )
    {
        var path = frame.line_number ;
        if( path.length >= max_line_number_length )
            return path ;
         return path + string.nfill( max_line_number_length - path.length, ' ' );
    }

    private string get_printable_file_short_path( Frame frame )
    {
        var path = frame.file_short_path ;
        if( path.length >= max_file_name_length )
            return path ;
         return path + string.nfill( max_file_name_length - path.length, ' ' );
    }

    public void print ()
    {
        var header = "An error occured (%s)\n\n".printf(get_signal_name()) ;
        if( first_vala != null )
            header = "An error occured (%s) in %s, line %s in %s\n\n".printf(
                get_signal_name(),
                first_vala.file_short_path,
                first_vala.line_number,
                get_printable_function(first_vala)) ;

        stdout.printf(header);
        int i = 1 ;
        foreach( var frame in frames )
        {

            if( frame.function != "" )
            {
                //     #2  ./OtherModule.c      line 80      in 'other_module_do_it'
                //         at /home/cran/Projects/noise/noise-perf-instant-search/tests/errors/module/OtherModule.vala:10
                var str = " %s  #%d  %s   line %s    in %s\n" ;
                if( frame.line_number == "" )
                {
                    str = " %s  #%d  <unknown>  %s  in %s\n" ;
                    var lead = " " ;
                    if( frame == first_vala )
                        lead = "*" ;
                    str = str.printf(
                        lead,
                        i,
                        string.nfill( max_file_name_length + max_line_number_length -1, ' ' ),
                        get_printable_function(frame) ) ;
                }
                else
                {
                    var lead = " " ;
                    if( frame == first_vala )
                        lead = "*" ;
                    str = str.printf(
                        lead,
                        i,
                        get_printable_file_short_path( frame),
                        get_printable_line_number(frame),
                        get_printable_function(frame) ) ;
                }
                stdout.printf ( str);
                str = "        at %s\n".printf( frame.file_path) ;
                stdout.printf ( str);

                i++ ;
            }
        }
    }

    public static void register_handlers ()
    {
        Process.@signal (ProcessSignal.SEGV, handler);
        Process.@signal (ProcessSignal.ABRT, handler);
    }

    public static void handler (int sig) {
        Stacktrace stack = new Stacktrace ();
        stack.print ();
        Process.exit (1);
    }
}
