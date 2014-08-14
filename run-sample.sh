clear
rm ./samples/sample1
valac -g --save-temps -X -rdynamic --pkg linux --pkg gee-0.8 -o ./samples/sample1 ./samples/vala_file.vala ./samples/errors.vala ./src/Stacktrace.vala ./samples/module/OtherModule.vala
./samples/sample1
