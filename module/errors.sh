clear
rm errors
# valac -g -X -rdynamic -X "-Wl,-export-dynamic" --pkg linux -o errors OtherModule.vala errors.vala
valac -g --save-temps -X -rdynamic --pkg linux --pkg gee-0.8 -o errors vala_file.vala errors.vala Stacktrace.vala module/OtherModule.vala
./errors