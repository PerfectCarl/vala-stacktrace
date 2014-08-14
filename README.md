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

To run, execute 

```
./run_samples.sh
```

[Null reference sample](/samples/error_sigsegv.vala)
--------------------------------------------
See screenshot above
> Signal intercepted: `SIGSEV`

[Uncaught error](/samples/error_sigabrt.vala)
--------------------------------------
![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigabrt.png)

> Signal intercepted: `SIGABRT`

[Critical assert](/samples/error_sigtrap.vala)
---------------------------------------
To make your application halts at the first `CRITICAL` trace, you must write: 
```
	int main (string[] args) {
		Stacktrace.crash_on_critical ();
	    Stacktrace.register_handlers () ;
	    
		stdout.printf("  This program will crash with an assert error!\n" ) ;
		
	    this_will_crash () ;
	    return 0 ;
	}

```

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigtrap.png)

> Signal intercepted: `SIGTRAP`
