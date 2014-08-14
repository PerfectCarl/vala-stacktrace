Introduction
============

Vala stracktrace displays the application stacktrace when your application crashes (yes, like all those other modern languages).

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

And build your application with `-rdynamic` 
```
valac -g -X -rdynamic -o sample <your vala files>
```

The output is :

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack-segv.png)

[Sample](/samples)
==================

[Null reference sample](/samples/error_sigsev.vala)
--------------------------------------------
See screenshot above
> Signal intercepted: `SIGSEV`

[Uncaught error](/samples/error_sigabrt.vala) (causing `SIGABRT`)
--------------------------------------
![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack-abrt.png)

> Signal intercepted: `SIGABRT`

[Critical assert](/samples/error_sigtrap.vala) (causing `SIGTRAP`)
---------------------------------------
To make your applicatio halts at the first `CRITICAL` trace, you must write: 
```
	int main (string[] args) {
		Stacktrace.crash_on_critical ();
	    Stacktrace.register_handlers () ;
	    
		stdout.printf("  This program will crash with an assert error!\n" ) ;
		
	    this_will_crash () ;
	    return 0 ;
	}

```

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack-trap.png)

> Signal intercepted: `SIGTRAP`
