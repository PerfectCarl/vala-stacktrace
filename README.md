
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

## How does it work?

## Build instructions

# Samples
[Samples](/samples) are provided. 

To compile and run the samples, execute 

```
./run_samples.sh
```

## [Changelog](CHANGELOG.md)

