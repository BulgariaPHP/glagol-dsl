module BuildTests

import IO;
import Map;
import String;

private set[loc] collectTestFiles(loc location)
{
    set[loc] testFiles = {};

    for (current <- location.ls) {
        if (current.extension == "rsc") {
            testFiles += current;
        }
        else if (isDirectory(current)) {
            try {
                current.ls;
                testFiles += collectTestFiles(current);
            } catch: ;
        }
    }

    return testFiles;
}

public void main(list[str] args)
{
    loc testsLoc = |cwd:///Test|;

    testFiles = collectTestFiles(testsLoc);

    list[str] modules = [moduleName | file <- testFiles, line := readFileLines(file)[0], /module <moduleName:[a-zA-Z0-9:]+?>$/i := line];
    map[str function, loc location] functions = (function : file | file <- testFiles, line <- readFileLines(file), /test bool <function:.+?>\(\)/i := line);
    
    str fnMap = ("" | it + "<f>:|<functions[f].uri>|," | f <- functions );

    str testAggregate = "module Tests
                        '
                        'import IO;
                        'import List;
                        'import Exception;
                        'import Map;
                        'import util::Math;
                        '<for (moduleName <- modules) {>import <moduleName>;
                        '<}>
                        '
                        'private list[str] errorMessages = [];
                        '
                        'private int testsPassed = 0;
                        '
                        'private void runTest(bool () t, loc location) {
                        '   try {
                        '       if (t()) println(\"\<t\>\");
                        '       else {
                        '           errorMessages += \"Test \<t\> failed in \<location.path\>\";
                        '           print(\"F\");
                        '       }
                        '       testsPassed += 1;
                        '       if (testsPassed % 30 == 0) println(\" \<toInt((toReal(testsPassed)/<toReal("<size(functions)>")>)*100)\>%\");
                        '   } catch e: {
                        '       throw \"Test \<t\> threw an exception (located in \<location.path\>) with text \\\'\<e\>\\\'\";
                        '       return;
                        '   }
                        '} 
                        '
                        'public int main(list[str] args) {
                        '
                        '   map[bool () fn, loc file] tests = (<substring(fnMap, 0, size(fnMap) - 1)>);
                        '
                        '   for (t \<- tests) runTest(t, tests[t]);
                        '
                        '   println(\" 100%\");
                        '
                        '   if (size(errorMessages) \> 0) {
                        '       println();
                        '       println(\"Not all tests passed:\");
                        '       for (error \<- errorMessages) println(error);
                        '   } else {
                        '       println(\"OK\");
                        '   }
                        '
                        '   println(\"Total tests: \<size(tests)\>, successful: \<size(tests) - size(errorMessages)\>, failed: \<size(errorMessages)\>\");
                        '
                        '   return size(errorMessages) \> 0 ? 1 : 0;
                        '}
                        '";

    writeFile(testsLoc.parent + "Tests.rsc", testAggregate);
}
