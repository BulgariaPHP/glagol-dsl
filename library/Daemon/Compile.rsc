module Daemon::Compile

import Daemon::Response;
import Compiler::Compiler;
import lang::json::IO;
import lang::json::ast::JSON;
import IO;
import String;
import Parser::ParseCode;
import analysis::grammars::Ambiguity;
import Message;
import Daemon::Socket::Sockets;
import Exceptions::ParserExceptions;
import Exceptions::ConfigExceptions;
import Exceptions::TransformExceptions;
import Utils::SystemEnv;

private data Command = compileCmd(map[loc, str] sources);

public int main(list[str] args) {

    int port = toInt(args[0]);

	println("About to create server socket on port <port>...");
	
	int socketId = createServerSocket(port);
	
	println("Created server socket on port <port>.");
	
	listenForCompileSignals(socketId);
	
    closeServerSocket(socketId);
    
    return 0;
}

private str getInput(int listenerId) {
	println("Trying to get input from listener <listenerId>...");

    str input = trim(readFrom(listenerId));
    
    return (input == "" || input == null) ? getInput(listenerId) : input;
}

public void listenForCompileSignals(int socketId) {
	println("About to create a listener on socket with ID <socketId>...");
	
	int listenerId = createListener(socketId);
	
	println("Created listener with ID <listenerId>...");
    
    controller(getInput(listenerId), listenerId);
    
    closeListener(listenerId);
    
    listenForCompileSignals(socketId);
}

private void controller(str inputStream, int listenerId) {

    if (inputStream == "quit") return;
        
    try {
        Command command = decodeJSON(inputStream);
        dispatch(command, listenerId);
    } catch Ambiguity(loc file, _, _): {
        respondWith(diagnose(parseCode(|file:///| + file.path, true)), listenerId);
    } catch e: ParseError(loc location): {
    	respondWith(err(
    		"Parse error at <location.path> starting on line <location.begin.line>, column <location.begin.column> " +
    		"and ends on line <location.end.line>, column <location.end.column>."
		), listenerId);
	} catch ConfigException e: {
		respondWith(err(e.msg), listenerId);
	} catch ParserException e: {
		respondWith(err("[<e.at.path><line(e.at)>] <e.msg>"), listenerId);
    } catch TransformException e: {
		respondWith(err("[<e.at.path><line(e.at)>] <e.msg>"), listenerId);
    }
    
    respondWith(end(), listenerId);
}

private void dispatch(compileCmd(map[loc, str] sources), int listenerId) = compile(sources, listenerId);

private Command decodeJSON(str inputStream) = decodeJSON(fromJSON(#JSON, inputStream));
private Command decodeJSON(JSON json) = decodeJSON(json.properties["command"].s, json);
private Command decodeJSON(s: "compile", object(map[str, JSON] properties)) = decodeJSON(s, properties["sources"].properties);
private Command decodeJSON("compile", map[str, JSON] sources) = compileCmd((|file:///| + f : c | f <- sources, string(str c) := sources[f]));

private str line(loc src) = ":<src.begin.line>" when src.begin? && src.begin.line?;
private str line(loc src) = "";
