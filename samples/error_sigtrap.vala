private void this_will_crash ()
{
	string content = "" ;
	size_t size = 0 ;
	// The compiler warns us: unhandled error `GLib.FileError'
    FileUtils.get_contents ("/do/not/exist/file.vala",out content, out size);
    message ("I haven't crashed") ;

}

int main (string[] args) {
	// Same as G_DEBUG=fatal-criticals in your environment variables
	Stacktrace.critical_handling = Stacktrace.CriticalHandler.CRASH;
    Stacktrace.register_handlers () ;
    
	stdout.printf("  This program will crash with an uncaught error which will be logged as CRITICAL!\n" ) ;
	
    this_will_crash () ;
    return 0 ;
}