clear
rm ./samples/sample_sigsegv
# Null reference
valac -g --save-temps -X -rdynamic --pkg linux --pkg gee-0.8 -o ./samples/sample_sigsegv ./samples/vala_file.vala ./samples/error_sigsegv.vala ./src/Stacktrace.vala ./samples/module/OtherModule.vala
./samples/sample_sigsegv

# Uncaught error
rm ./samples/sample_sigabrt
valac -g --save-temps -X -rdynamic --pkg linux --pkg gee-0.8 -o ./samples/sample_sigabrt ./samples/error_sigabrt.vala ./src/Stacktrace.vala
./samples/sample_sigabrt

# Critical assert
rm ./samples/sample_sigtrap
valac -g --save-temps -X -rdynamic --pkg linux --pkg gee-0.8 -o ./samples/sample_sigtrap ./samples/error_sigtrap.vala ./src/Stacktrace.vala
./samples/sample_sigtrap
