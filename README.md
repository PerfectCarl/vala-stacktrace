Introduction
============

Vala stracktrace displays the application stacktrace when your application crashes (yes, like all those other modern languages).

Just add the following lines : 

```
int main (string[] args) {
    Stacktrace.register_handlers () ;
	  
	  stdout.printf("  This program will crash !\n" ) ;

    this_will_crash () ;
    return 0 ;
}
```

The output is 

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/output.png)

[Sample](/samples)
==================
