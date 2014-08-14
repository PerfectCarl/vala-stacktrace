private void this_will_crash ()
{
	string content = "" ;
	size_t size = 0 ;
    FileUtils.get_contents ("/do/not/exist/file.vala",out content, out size);
}

int main (string[] args) {
	Stacktrace.crash_on_critical ();
    Stacktrace.register_handlers () ;
    
	stdout.printf("  This program will crash with an assert error!\n" ) ;
	
    this_will_crash () ;
    return 0 ;
}
