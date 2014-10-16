
This library displays the stacktrace when your vala application crashes (should it ever happen).

Just have `Stacktrace` register the handlers  : 

```java
int main (string[] args) {
    // register the handler
    Stacktrace.register_handlers () ;
	  
    stdout.printf("  This program will crash !\n" ) ;
    // The next call will crash because it uses a null reference
    this_will_crash () ;
    return 0 ;
}
```

... and build your application with `-rdynamic` 
```
valac -g -X -rdynamic -o sample <your vala files>
```

Your application will display a complete stacktrace before it crashes :

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigsegv.png)

## Documentation 

 * [Usage] (#usage)
 * [How does it work?] (#how-does-it-work)
 * [Samples] (#samples) 
 * [Changelog] (#changelog)

## Usage

The library can be used: 


## How does it work?

The library registers handlers for the `SIGABRT`, `SIGSEV` and `SIGTRAP` signals. It processes the stacktrace symbols provided by [Linux.Backtrace.symbols](http://valadoc.org/#!api=linux/Linux.Backtrace.symbols) and retreive the file name, line number and function name using the symbols and [addr2line](http://linux.die.net/man/1/addr2line).

> Note: it means that your application will spawn a synchronuous external processus. 

## Build instructions

# Samples
[Samples](/samples) are provided. 

To compile and run the samples, execute 

```
./run_samples.sh
```

## [Changelog](CHANGELOG.md)

