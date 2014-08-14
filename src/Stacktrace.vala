
public class Stacktrace {

    public class Frame
    {
        public string address  { get; private set; default = ""; }

        public string line { get; private set; default = ""; }

        public string line_number { get; private set; default = ""; }

        public string file_path { get; private set; default = ""; }

        public string file_short_path { get; private set; default = ""; }

        public string function { get; private set; default = ""; }

        public Frame( string address, string line, string function, string file_path, string file_short_path )
        {
            this._address = address;
            this._line = line;

            this._file_path = file_path;
            this._file_short_path = file_short_path;
            this._function = function;
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

    public enum Style {
        RESET = 0,
        BRIGHT =        1,
        DIM     = 2,
        UNDERLINE = 3,
        BLINK   = 4,
        REVERSE =        7,
        HIDDEN  = 8
    }

    public enum Colors {
        BLACK = 0,
        RED     = 1,
        GREEN   = 2,
        YELLOW = 3,
        BLUE    = 4,
        MAGENTA =        5,
        CYAN    = 6,
        WHITE =  7
    }

    public Gee.ArrayList<Frame> _frames = new Gee.ArrayList<Frame>();

    private Frame first_vala = null;

    private int max_file_name_length = 0;

    private int max_line_number_length = 0;

    private ProcessSignal sig;

    public Gee.ArrayList<Frame> frames {
        get
        {
            return _frames;
        }
    }

    public Stacktrace(ProcessSignal sig)
    {
        this.sig = sig;
        create_stacktrace ();
    }

    private string get_module_name ()
    {
        var path = new char[1024];
        Posix.readlink ( "/proc/self/exe", path );
        string result = (string) path;
        return result;
    }

    private string extract_short_file_path (string file_path)
    {
        var path = Environment.get_current_dir ();
        var i = file_path.index_of ( path );
        if( i>=0 )
            return file_path.substring ( path.length, file_path.length - path.length );
        return file_path;
    }

    private void create_stacktrace () {
        int frame_count = 100;
        int skipped_frames_count = 4;

        void*[] array = new void*[frame_count];

        _frames.clear ();
        first_vala = null;
        max_file_name_length = 0;

        int size = Linux.backtrace (array, frame_count);
        //Linux.backtrace_symbols_fd (array, size, Posix.STDERR_FILENO);
        # if VALA_0_26
        var strings = Linux.Backtrace.symbols ( array, size );
        # else
            unowned string[] strings = Linux.backtrace_symbols (array, size);
        // Needed because of some weird bug
        strings.length = size;
        # endif

        int[] addresses = (int[])array;
        string module = get_module_name ();
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

            string file_path  = "";
            string short_file_path = "";
            string l = "";
            if( file_line != "" )
            {
                file_path = extract_file_path (file_line);
                short_file_path  = extract_short_file_path (file_path);
                l = extract_line (file_line);
            } else
                file_path = extract_file_path_from ( str);
            //stdout.printf ("Building %d \n  . addr: [%s]\n  . ad_ : [%s]\n  . line: '%s'\n  . str : '%s'\n  . func: '%s'\n  . file: '%s'\n  . line: '%s'\n",
            //   i, addr, a, file_line, str, func, file_path, l);

            var frame = new Frame ( a, file_line, func, file_path, short_file_path  );

            if( first_vala == null && file_path.has_suffix (".vala"))
                first_vala = frame;

            if( short_file_path.length > max_file_name_length )
                max_file_name_length = short_file_path.length;
            if( l.length > max_line_number_length )
                max_line_number_length = l.length;
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
                return result.strip ();
            }
        }
        return "";
    }

    private string extract_file_path_from ( string str)
    {
        if( str =="" )
            return "";
        var start = str.index_of ( "(");
        if( start >= 0 )
        {
            return str.substring (0, start ).strip ();
        }
        return str.strip ();
    }

    private string extract_file_path ( string line )
    {
        if( line == "" )
            return "";
        var start = line.index_of ( ":");
        if( start>=0 )
        {
            var result = line.substring (0, start );
            return result.strip ();
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
            var result = line.substring (start + 1, line.length - start - 1 );
            var end = result.index_of ( "(");
            if( end >=0)
            {
                result = result.substring (0, end);
            }
            return result.strip ();
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
                return result.strip ();
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
        }
    }

    // Poor's man demangler. libunwind is another dep
    // module : app
    // address : 0x007f80
    // output : /home/cran/Projects/noise/noise-perf-instant-search/tests/errors.vala:87
    string get_line ( string module, string address ) {
        var cmd = "addr2line -e %s %s".printf ( module, address);
        var result = execute_command_sync_get_output ( cmd );
        result = result.replace ("\n", "");
        return result;
    }

    private string get_reset_code ()
    {
        //return get_color_code (Style.RESET, Colors.WHITE, Colors.BLACK);
		
        return "\x1b[0m";
    }

    private string get_reset_style ()
    {
        return get_color_code (Style.DIM, Colors.WHITE, background_color);
    }

    private string  get_color_code (Style attr, Colors fg, Colors bg = background_color)
    {
        /* Command is the control command to the terminal */
		if( bg == Colors.BLACK)
			return "%c[%d;%dm".printf ( 0x1B, (int)attr, (int)fg + 30);
		else
			return "%c[%d;%d;%dm".printf ( 0x1B, (int)attr, (int)fg + 30, (int)bg + 40);
    }

    private string get_signal_name ()
    {
        return sig.to_string ();
    }

    private string get_printable_function (Frame frame, int padding = 0)
    {
        var result = "";
        if( frame.function == "" )
            result = "<unknown>";
        else {
            var s = "";
            int count = padding - get_signal_name ().length;
            if (padding != 0 && count >0)
                s = string.nfill ( count, ' ');
            result =  "'" + frame.function + "'" + s;
        }
        return get_color_code (Style.BRIGHT, Colors.WHITE) + result + get_reset_code ();
    }

    private string get_printable_line_number ( Frame frame )
    {
        var path = frame.line_number;
        var result = "";
        if( path.length >= max_line_number_length )
            result = path;
        else
            result = path + string.nfill ( max_line_number_length - path.length, ' ' );
        return result;
    }

    private string get_printable_file_short_path ( Frame frame, bool pad = true )
    {
        var path = frame.file_short_path;
        var result = "";
        var color = get_color_code (Style.BRIGHT, Colors.WHITE);
        if( path.length >= max_file_name_length && !pad)
            result = color + path  + get_reset_style ();
        else {
            result =  color + path + get_reset_style ();
            result =  result + string.nfill ( max_file_name_length - path.length, ' ' );
        }
        return result;
    }

    Colors background_color = Colors.BLACK;
    int title_length = 0;

    private string get_printable_title ()
    {
        var c = get_color_code (Style.DIM, Colors.WHITE, Colors.RED);
        var color = get_color_code (Style.BRIGHT, Colors.WHITE, Colors.RED);

        var result = "%sAn error occured %s(%s)%s".printf (
            c,
            color,
            get_signal_name (),
            get_reset_style ());
        title_length =  get_signal_name ().length;
        return result;
    }

    private string get_reason ()
    {
        //var c = get_reset_code();
        var color = get_color_code (Style.BRIGHT, Colors.WHITE, Colors.BLACK);
        if( sig == ProcessSignal.TRAP ) {
            return "The reason is likely %san uncaught error%s".printf (
                color, get_reset_code ());
        }
        if( sig == ProcessSignal.ABRT ) {
            return "The reason is likely %sa failed assertion (assert...)%s".printf (
                color, get_reset_code ());
        }
        if( sig == ProcessSignal.SEGV ) {
            return "The reason is likely %sa null reference being used%s".printf (
                color, get_reset_code ());
        }
        return "Unknown reason.";
    }

    public void print ()
    {
        background_color = Colors.RED;
        var header = "%s\n\n".printf (
            get_printable_title ());
        if( first_vala != null ) {
            header = "%s in %s, line %s in %s\n".printf (
                get_printable_title (),
                get_printable_file_short_path ( first_vala, false),
                first_vala.line_number,
                get_printable_function (first_vala)+get_reset_code());
            title_length += first_vala.line_number.length +
                            first_vala.function.length +
                            first_vala.file_short_path.length;
        }
        stdout.printf (header);
        background_color = Colors.BLACK;
        var reason = get_reason ();
        stdout.printf ( "   %s.\n\n",
            reason );
        int i = 1;
        foreach( var frame in _frames )
        {

            if( frame.function != "" )
            {
                //     #2  ./OtherModule.c      line 80      in 'other_module_do_it'
                //         at /home/cran/Projects/noise/noise-perf-instant-search/tests/errors/module/OtherModule.vala:10
                var str = " %s  #%d  %s   line %s    in %s\n";
                background_color = Colors.BLACK;
                var lead = " ";
                var ending1 = "";
                var function_padding = 0;
                if( frame == first_vala )
                {
                    lead = "*";
                    background_color = Colors.RED;
                    ending1 = string.nfill (66 - title_length, ' ' );
                    function_padding = 22;
                }
                if( frame.line_number == "" )
                {
                    str = " %s  #%d  <unknown>  %s  in %s\n";
                    str = str.printf (
                        lead,
                        i,
                        string.nfill ( max_file_name_length + max_line_number_length - 1, ' ' ),
                        get_printable_function (frame) );
                } else {
                    str = str.printf (
                        lead,
                        i,
                        get_printable_file_short_path ( frame),
                        get_printable_line_number (frame),
                        get_printable_function (frame, function_padding) );
                }
                stdout.printf ( str);

                str = "        at %s\n".printf (
                    frame.file_path);
                stdout.printf ( str);

                i++;
            }
        }
    }

    public static void register_handlers ()
    {
        Process.@signal (ProcessSignal.SEGV, handler);
        Process.@signal (ProcessSignal.ABRT, handler);
        Process.@signal (ProcessSignal.TRAP, handler);
    }

    public static void crash_on_critical ()
    {
        //var variables = Environ.get ();
        //Environ.set_variable (variables, "G_DEBUG", "fatal-criticals" );
        Log.set_always_fatal (LogLevelFlags.LEVEL_CRITICAL);
    }

    public static void handler (int sig) {
        Stacktrace stack = new Stacktrace ((ProcessSignal)sig);
        stack.print ();
        Process.exit (1);
    }
}
