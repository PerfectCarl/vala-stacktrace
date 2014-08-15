Introduction
============

This project displays the stacktrace when your vala application crashes (should it ever happen).

Just add the following lines : 

```java
int main (string[] args) {
    Stacktrace.register_handlers () ;
	  
    stdout.printf("  This program will crash !\n" ) ;
    // Null deferencing
    this_will_crash () ;
    return 0 ;
}
```

... and build your application with `-rdynamic` 
```
valac -g -X -rdynamic -o sample <your vala files>
```

The output is :

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigsegv.png)

Samples
==================
[Samples](/samples) are provided. 

To compile and run the samples, execute 

```
./run_samples.sh
```

[Null reference sample](/samples/error_sigsegv.vala)
--------------------------------------------
See screenshot above
> Signal intercepted: `SIGSEV`

[Uncaught error](/samples/error_sigtrap.vala)
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
	Stacktrace.crash_on_critical ();
	Stacktrace.register_handlers () ;
	
	stdout.printf("  This program will crash with an uncaught error which will be logged as CRITICAL!\n" ) ;
	
	this_will_crash () ;
	return 0 ;
}

```
![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigtrap.png)

> Signal intercepted: `SIGTRAP`

[Critical assert](/samples/error_sigabrt.vala)
---------------------------------------
```java
private void this_will_crash ()
{
	var hi = "johnny !" ;
	assert (hi == "wiseau");
	message ("I haven't crashed") ;
}

int main (string[] args) {
	Stacktrace.register_handlers () ;
	
	stdout.printf("  This program will crash with a failed assert!\n" ) ;
	
	this_will_crash () ;
	return 0 ;
}

```

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigabrt.png)

> Signal intercepted: `SIGABRT`

[Setting colors](/samples/error_colors.vala)
---------------------------------------
You can set the background and highlight color with `BLACK`, `BLUE`,`CYAN`,`GREEN`,`MAGENTA`,`RED`,`WHITE` and `YELLOW`.

```java
	int main (string[] args) {
		// Soothing, uh?
		Stacktrace.highlight_color = Stacktrace.Color.GREEN ;
		Stacktrace.error_background = Stacktrace.Color.WHITE ;
		Stacktrace.register_handlers () ;
		
		stdout.printf("  This program will crash with fancy colors!\n" ) ;
		
		this_will_crash () ;
		return 0 ;
	}

```

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_colors.png)

