[Setting colors](../samples/error_colors.vala)
---------------------------------------
You can set the background and highlight color with `BLACK`, `BLUE`,`CYAN`,`GREEN`,`MAGENTA`,`RED`,`WHITE` and `YELLOW`.

```java
	int main (string[] args) {
		// Soothing, uh?
		Stacktrace.default_highlight_color = Stacktrace.Color.GREEN ;
		Stacktrace.default_error_background = Stacktrace.Color.WHITE ;
		Stacktrace.register_handlers () ;
		
		stdout.printf("  This program will crash with fancy colors!\n" ) ;
		
		this_will_crash () ;
		return 0 ;
	}

```

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_colors.png)
