
public class Namespace.SomeClass
{
    public void exec ()
    {
        OtherModule module = new OtherModule() ;
        module.do_it () ;
    }
}

private void this_will_crash ()
{
    var some = new Namespace.SomeClass() ;
    some.exec () ;
}

int main (string[] args) {
    Stacktrace.register_handlers () ;
    
	stdout.printf("  This program will crash !\n" ) ;
	
    this_will_crash () ;
    return 0 ;
}
