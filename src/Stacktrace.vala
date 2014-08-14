
public class Stacktrace {

    public class Frame
    {
        string address  { get; private set; }

        string line { get; private set; }

        public Frame( string address, string line, string function_name )
        {
            this._address = address;
            this._line = line;
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

    private void create_stacktrace () {
        int frame_count = 100;
        int skipped_frames_count = 4;

        void*[] array = new void*[frame_count];

        _frames.clear ();
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
        // First ones are the handler
        for( int i = skipped_frames_count; i < size; i++ )
        {
            //var str = strings[i] ;
            int address = addresses[i];
            string str = strings[i];

            string a = "%#08x".printf ( address );
            string addr = extract_address (str);
            string file_line = get_line ( "errors", addr );
            if( file_line == "??:0" || file_line == "??:?")
                file_line = "";
            string func = extract_function_name (str);
            string file_path = extract_file_path (file_line);
            string l = extract_line (file_line);
            stdout.printf ("Building %d \n  . addr: [%s]\n  . ad_ : [%s]\n  . line: '%s'\n  . str : '%s'\n  . func: '%s'\n  . file: '%s'\n  . line: '%s'\n",
                i, addr, a, file_line, str, func, file_path, l);

            var frame = new Frame ( a, file_line, func  );
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

    private string extract_line ( string line )
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

    public void print ()
    {
        foreach( var frame in frames )
        {
            stdout.printf ( "%s\n", frame.to_string () );
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