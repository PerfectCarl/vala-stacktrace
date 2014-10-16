[Uncaught error](../samples/error_sigtrap.vala)
--------------------------------------
Uncaught errors are logged with `CRITICAL` level also you need to add `Stacktrace.crash_on_critical ()` if you want your application to halt: 
```java
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
	// The other values are : 
	//  - PRINT_STACKTRACE: a full stacktrace is displayed
	//  - IGNORE: nothing is done when SIGTRAP is recieved 
	Stacktrace.critical_handling = Stacktrace.CriticalHandler.CRASH;
	Stacktrace.register_handlers () ;
	
	stdout.printf("  This program will crash with an uncaught error which will be logged as CRITICAL!\n" ) ;
	
	this_will_crash () ;
	return 0 ;
}

```
![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigtrap.png)

> Signal intercepted: `SIGTRAP`
