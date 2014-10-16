[Critical assert](../samples/error_sigabrt.vala)
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
