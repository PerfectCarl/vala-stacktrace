
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

	public enum Style {
		RESET = 0,
		BRIGHT =	1, 
		DIM	=2,
		UNDERLINE =3,
		BLINK	=4,
		REVERSE=	7,
		HIDDEN	=8
	}

	public enum Colors {
		BLACK =	0,
		RED	=1,
		GREEN	=2,
		YELLOW=	3,
		BLUE	=4,
		MAGENTA=	5,
		CYAN	=6,
		WHITE=	7
	}
	
    public Gee.ArrayList<Frame> _frames = new Gee.ArrayList<Frame>();

    private  Frame first_vala = null ;

    private int max_file_name_length = 0 ;

    private int max_line_number_length = 0 ;

	private ProcessSignal sig ;
	
    public Gee.ArrayList<Frame> frames {
        get
        {
            return _frames;
        }
    }

    public Stacktrace(ProcessSignal sig)
    {
		this.sig = sig ;
        create_stacktrace ();
    }

    private string get_module_name ()
    {
		var path = new char[1024] ;
		Posix.readlink( "/proc/self/exe", path ) ;
		string result = (string) path ; 
        return result ;
    }

    private string extract_short_file_path (string file_path)
    {
        var path = Environment.get_current_dir () ;
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
        //Linux.backtrace_symbols_fd (array, size, Posix.STDERR_FILENO);
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
            //stdout.printf ("Building %d \n  . addr: [%s]\n  . ad_ : [%s]\n  . line: '%s'\n  . str : '%s'\n  . func: '%s'\n  . file: '%s'\n  . line: '%s'\n",
            //   i, addr, a, file_line, str, func, file_path, l);

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
                return result.strip();
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
            return str.substring (0, start ).strip() ;
        }
        return str.strip() ;
    }

    private string extract_file_path ( string line )
    {
        if( line == "" )
            return "";
        var start = line.index_of ( ":");
        if( start>=0 )
        {
            var result = line.substring (0, start );
            return result.strip();
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
            var end = result.index_of ( "(") ;
            if( end >=0)
            {				
				result = result.substring (0, end)  ;
			}
            return result.strip();
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
                return result.strip();
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

	private string get_reset_code()
	{
		return "\x1b[0m" ;
	}
	
	private string  get_color_code(Style attr, Colors fg, Colors bg)
	{	
		/* Command is the control command to the terminal */
		var result = "%c[%d;%d;%dm".printf( 0x1B, (int)attr, (int)fg + 30, (int)bg + 40);
		return result ;
	}

    private string get_signal_name()
    {
        return sig.to_string() ;
    }
	
    private string get_printable_function (Frame frame)
    {
		var result = "" ;
        if( frame.function == "" )
            result= "<unknown>" ;
		else
			result =  "'" + frame.function + "'" ;
		
        return get_color_code(Style.BRIGHT, Colors.WHITE, Colors.BLACK) + result + get_reset_code() ;
    }

    private string get_printable_line_number( Frame frame )
    {
        var path = frame.line_number ;
        var result = "" ;
        if( path.length >= max_line_number_length )
            result = path ;
		else
			result = path + string.nfill( max_line_number_length - path.length, ' ' );
         return result;
    }

    private string get_printable_file_short_path( Frame frame )
    {
        var path = frame.file_short_path ;
        var result = "" ;
		var color = get_color_code(Style.BRIGHT, Colors.WHITE, Colors.BLACK) ;
        if( path.length >= max_file_name_length )
            result = color+ path  + get_reset_code();
         else
         {
			 result =  color + path + get_reset_code() ;
         result =  result + string.nfill( max_file_name_length - path.length, ' ' );
		
		 }
         return result ;
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
        foreach( var frame in _frames )
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
        Process.@signal (ProcessSignal.TRAP, handler);
    }

	public static void crash_on_critical ()
	{
		var variables = Environ.get () ;
		Environ.set_variable (variables, "G_DEBUG" ,"fatal-criticals" ) ;
	}
	
    public static void handler (int sig) {
        Stacktrace stack = new Stacktrace ((ProcessSignal)sig);
        stack.print ();
        Process.exit (1);
    }
}
