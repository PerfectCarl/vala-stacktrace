[Null reference sample](../samples/error_sigsegv.vala)
--------------------------------------------

```java
int main (string[] args) {
    Stacktrace.register_handlers () ;
	  
    stdout.printf("  This program will crash !\n" ) ;
    // Null deferencing
    this_will_crash () ;
    return 0 ;
}
```

The output is :

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigsegv.png)

> Signal intercepted: `SIGSEV`
