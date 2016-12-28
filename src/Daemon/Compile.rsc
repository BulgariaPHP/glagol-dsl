module Daemon::Compile

import Daemon::TcpServer;
import Compiler::Compiler;
import lang::json::IO;
import lang::json::ast::JSON;
import IO;
import String;
import Parser::ParseCode;
import Ambiguity;

private alias Command = tuple[str command, loc path];

public int main(list[str] args) {
	println("Opening socket...");
	listenForCompileSignals(toInt(args[0]));
}

public void listenForCompileSignals(int port) {
    openSocket(port, controller);
}

private void controller(str inputStream) {

    if (inputStream == "quit") return;
        
    try {
        Command command = decodeJSON(inputStream);
        dispatch(command);
    } catch Ambiguity(loc file, _, _): {
        iprintln(diagnose(parseCode(|file:///| + file.path, true)));
    } catch e: {
        iprintln(e);
        socketWriteLn("Error: <e>");
    }
}

private void dispatch(Command command) {
    switch (command.command) {
        case "compile":
            compile(command.path);
    }
}

private Command decodeJSON(str inputStream) {
    JSON json = fromJSON(#JSON, inputStream);
    
    return <json.properties["command"].s, |file:///| + json.properties["path"].s>;
}
