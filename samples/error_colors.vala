private void this_will_crash ()
{
	var hi = "johnny !" ;
	assert (hi == "wiseau");
    message ("I haven't crashed") ;
}

int main (string[] args) {
	// Soothing, uh?
	Stacktrace.highlight_color = Stacktrace.Color.GREEN ;
	Stacktrace.error_background = Stacktrace.Color.WHITE ;
    Stacktrace.register_handlers () ;

	stdout.printf("  This program will crash with fancy colors!\n" ) ;

    this_will_crash () ;
    return 0 ;
}
