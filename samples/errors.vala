
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

    this_will_crash () ;
    return 0 ;
}