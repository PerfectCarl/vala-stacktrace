private void this_will_crash ()
{
    FileStream stream = FileStream.open ("/do/not/exist/file.vala", "r");
	assert (stream != null);
    
}

int main (string[] args) {
    Stacktrace.register_handlers () ;
    
	stdout.printf("  This program will crash with an assert error!\n" ) ;
	
    this_will_crash () ;
    return 0 ;
}
