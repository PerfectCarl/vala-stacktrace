/*
 * Copyright (C) 2014 PerfectCarl - https://github.com/PerfectCarl/vala-stacktrace
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
private void this_will_crash () {
    var hi = "johnny !";
    assert (hi == "wiseau");
    message ("I haven't crashed");
}

int main (string[] args) {
    // Soothing, uh?
    Stacktrace.default_highlight_color = Stacktrace.Color.GREEN;
    Stacktrace.default_error_background = Stacktrace.Color.WHITE;
    Stacktrace.register_handlers ();

    stdout.printf ("  This program will crash with fancy colors!\n");

    this_will_crash ();
    return 0;
}