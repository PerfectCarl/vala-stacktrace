
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

... and build your application with `-X -rdynamic` and required dependencies
```
valac -g -X -rdynamic --pkg linux --pkg gee-0.8  -o sample <your vala files>
```

Your application will display a complete stacktrace before it crashes :

![](https://raw.githubusercontent.com/PerfectCarl/vala-stacktrace/master/doc/stack_sigsegv.png)

## Documentation 

 * [Usage] (#usage)
 * [How does it work?] (#how-does-it-work)
 * [Samples] (#samples) 
 * [Changelog] (#changelog)

## Usage

The library format the stacktrace using colors [`default_highlight_color`](/doc/api.md#default_highlight_color) and [`default_error_background`](/doc/api.md#default_error_background) hiding the system libraries (libc, etc) for which there are usually no information available (that feature can be enabled via [`hide_installed_libraries`](/doc/api.md#hide_installed_libraries)`.

The library has two use cases:
 * crash interception: when a vala application crashes it emits a signal depending on the nature of error. Those signals are intercepted and before the application exits, the application stacktrace is displayed
 * tracing a call graph: a `Stacktrace` can be instantiated and displayed at any point [in your code](/doc/instanciation.md).

The following signals are intercepted:

| Signal       | Likely reason          | Note                                                              |
|--------------|------------------------|-------------------------------------------------------------------|
| [SIGABRT][1] | Failed critical assert |                                                                   |
| [SIGSEV][2]  | Using a null reference |                                                                   |
| [SIGTRAP][3] | Uncaught error         | Try adding a `throw` in your code to handle this error properly |

[1]: /doc/sigabrt.md
[2]: /doc/sigsev.md
[3]: /doc/sigtrap.md


## How does it work?

The library registers handlers for the `SIGABRT`, `SIGSEV` and `SIGTRAP` signals. 

It processes the stacktrace symbols provided by [Linux.Backtrace.symbols](http://valadoc.org/#!api=linux/Linux.Backtrace.symbols) and retreive the file name, line number and function name using the symbols and calling [addr2line](http://linux.die.net/man/1/addr2line) **multiple times**.

> Note: it means that your application will spawn synchronuous external processes. 


This library is [Apache licensed](http://www.apache.org/licenses/LICENSE-2.0) and has the following vala dependencies: 
  - linux
  - gee-0.8

## Samples
[Samples](/samples) are provided for a wide variety of use cases: 
  - [SIGABRT][1] : failed critical assert
  - 


To compile and run all the samples, execute 

```
./run_samples.sh
```

## [Changelog](CHANGELOG.md)

