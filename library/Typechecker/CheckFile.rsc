module Typechecker::CheckFile

import Config::Config;
import Config::Reader;
import Typechecker::Env;
import Typechecker::Artifact;
import Typechecker::Imports;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;
import String;

public TypeEnv checkAST(Config config, list[Declaration] ast) = (newEnv(ast) | checkFile(config, f, cleanCopy(it)) | f <- ast);

@doc{
Runs typecheck on Glagol file:
    - Check if location corresponds to module definition including namespace
    - Typecheck the imports
    - Typecheck the enclosed artifact
}
public TypeEnv checkFile(Config config, f:file(loc src, m:\module(ns, list[Declaration] imports, Declaration artifact)), TypeEnv env) = 
    checkArtifact(artifact,
    	setContext(m, checkImports(
    	   imports, checkLocVsModule(|file:///src|, f, setLocation(src, env))
    	))
	);

@doc="Module location correspondence typecheck failure case"
public TypeEnv checkLocVsModule(loc sources, file(loc src, m:\module(ns, imports, Declaration artifact)), TypeEnv env) =
    addError(src, "Wrong file name, does not follow namespace declaration and/or artifact name. " + 
        "Expected <constructFileFromModule(sources, m).uri>, got <src.uri>.", env)
    when src.uri != constructFileFromModule(sources, m).uri;

@doc="Module location correspondence typecheck SUCCESS case (returns untouched env directly)"
public TypeEnv checkLocVsModule(loc sources, file(loc src, m:\module(ns, imports, Declaration artifact)), TypeEnv env) = env;

@doc="Constructrs supposable file name based on entity name and namespace"
public loc constructFileFromModule(loc sources, \module(Declaration ns, _, entity(GlagolID name, _))) = 
    sources + namespaceToString(ns, "/") + "<name>.g";

@doc="Constructrs supposable file name based on repository name and namespace"
public loc constructFileFromModule(loc sources, \module(Declaration ns, _, repository(GlagolID name, _))) = 
    sources + namespaceToString(ns, "/") + "<name>Repository.g";

@doc="Constructrs supposable file name based on value object name and namespace"
public loc constructFileFromModule(loc sources, \module(Declaration ns, _, valueObject(GlagolID name, _, notProxy()))) = 
    sources + namespaceToString(ns, "/") + "<name>.g";
    
@doc="Suspends check for file name on value object proxies"
public loc constructFileFromModule(loc sources, m: \module(Declaration ns, _, valueObject(GlagolID name, _, proxyClass(str s)))) = 
    m@src;
    
@doc="Constructrs supposable file name based on utility name and namespace"
public loc constructFileFromModule(loc sources, \module(Declaration ns, _, util(GlagolID name, _))) = 
    sources + namespaceToString(ns, "/") + "<name>.g";
    
@doc="Constructrs supposable file name based on controller name and namespace"
public loc constructFileFromModule(loc sources, \module(Declaration ns, _, controller(GlagolID name, _, _, _))) = 
    sources + namespaceToString(ns, "/") + "<name>.g";
    
