# Introduction

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

# Samples
[Samples](/samples) are provided. 

To compile and run the samples, execute 

```
./run_samples.sh
```
# Usage

# How does it work?

# How to build?

# [Changelog](CHANGELOG.md)

