module Compiler::Compiler

import Daemon::TcpServer;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::PHP;
import Parser::ParseAST;
import Config::Config;
import Compiler::PHP::Compiler;
import Compiler::EnvFiles;
import Transform::Glagol2PHP::Namespaces;
import IO;

public void compile(loc projectPath) {
	Config config = loadGlagolConfig(projectPath);
    list[loc] sourceFiles = findAllSourceFiles(projectPath);
    
    list[Declaration] glagolParsed = [ast | fileLoc <- sourceFiles, Declaration ast := parseModule(fileLoc)];
        
    for (l <- glagolParsed, out := toPHPScript(<config.framework, config.orm>, l.\module), str outputFile <- out) {
    	createSourceFile(outputFile, toCode(out[outputFile]), config);
    	socketWriteLn("Compiled source file <outputFile>");
    }
    
    map[loc, str] envFiles = generateEnvFiles(config, glagolParsed);
    
    for (f <- envFiles) {
    	writeFile(f, envFiles[f]);
    	socketWriteLn("Created env file <f.path>");
    }
}

private void createSourceFile(str outputFile, str code, Config config) {
	writeFile(config.outPath + "src" + outputFile, code);
}

private list[loc] findAllSourceFiles(loc projectPath) {
    list[loc] sourceFiles = [path | path <- projectPath.ls, !isDirectory(path), path.extension == "g"];

    for (path <- projectPath.ls, isDirectory(path)) {
        sourceFiles += findAllSourceFiles(path);
    }
    
    return sourceFiles;
}
