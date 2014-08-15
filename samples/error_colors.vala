private void this_will_crash ()
{
	string content = "" ;
	size_t size = 0 ;
    FileUtils.get_contents ("/do/not/exist/file.vala",out content, out size);
    message ("I haven't crashed") ;

}

int main (string[] args) {
	Stacktrace.crash_on_critical ();
	// Soothing, uh?
	Stacktrace.highlight_color = Stacktrace.Color.GREEN ;
	Stacktrace.error_background = Stacktrace.Color.WHITE ;
    Stacktrace.register_handlers () ;

	stdout.printf("  This program will crash with fancy colors!\n" ) ;

    this_will_crash () ;
    return 0 ;
}
