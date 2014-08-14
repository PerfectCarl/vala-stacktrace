clear
rm ./samples/sample1
# First sample
valac -g --save-temps -X -rdynamic --pkg linux --pkg gee-0.8 -o ./samples/sample1 ./samples/vala_file.vala ./samples/errors.vala ./src/Stacktrace.vala ./samples/module/OtherModule.vala
./samples/sample1

# First sample
rm ./samples/sample2
valac -g --save-temps -X -rdynamic --pkg linux --pkg gee-0.8 -o ./samples/sample2 ./samples/error_assert.vala ./src/Stacktrace.vala
./samples/sample2

rm ./samples/sample3
valac -g --save-temps -X -rdynamic --pkg linux --pkg gee-0.8 -o ./samples/sample3 ./samples/error_exceptions.vala ./src/Stacktrace.vala
G_DEBUG=fatal-criticals ./samples/sample3
