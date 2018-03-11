module Parser::Converter::Artifact

import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;
import Syntax::Concrete::Grammar;
import Parser::Converter::Declaration::Constructor;
import Parser::Converter::Declaration::Method;
import Parser::Converter::Annotation;

public Declaration convertAnnotatedArtifact(a: (AnnotatedArtifact) `<Artifact artifact>`, ParseEnv env) = 
	convertArtifact(artifact, env);
    
public Declaration convertAnnotatedArtifact(a: (AnnotatedArtifact) `<Annotation* annotations><Artifact artifact>`, ParseEnv env) = 
	convertArtifact(artifact, env)[
    	@annotations = convertAnnotations(annotations, env)
    ];

public Declaration convertArtifact(a: (Artifact) `entity <ArtifactName name> {<Declaration* declarations>}`, ParseEnv env) = 
	entity("<name>", [convertDeclaration(d, "<name>", "entity", env) | d <- declarations])[@src=a@\loc];

public Declaration convertArtifact(a: (Artifact) `repository for <ArtifactName name> {<Declaration* declarations>}`, ParseEnv env) =
	repository("<name>", [convertDeclaration(d, "<name>", "repository", env) | d <- declarations])[@src=a@\loc];

public Declaration convertArtifact(a: (Artifact) `proxy<PhpClassName phpClassName>as<Proxable proxy>`, ParseEnv env) =
	convertProxable(proxy, proxyClass("<phpClassName>")[@src=phpClassName@\loc], env);

public Declaration convertProxable(a: (Proxable) `value <ArtifactName name> {<ProxyDeclaration* declarations>}`, Proxy proxy, ParseEnv env) = 
	valueObject("<name>", [convertProxyDeclaration(d, "<name>", env) | d <- declarations], proxy)[@src=a@\loc];

public Declaration convertProxyDeclaration(a: (ProxyDeclaration) `<ProxyMethod m>`, str proxyName, ParseEnv env) = convertProxyMethod(m, env);
public Declaration convertProxyDeclaration(a: (ProxyDeclaration) `<ProxyConstructor c>`, str proxyName, ParseEnv env) = convertProxyConstructor(c, proxyName, env);

public Declaration convertProxyMethod(
    a: (ProxyMethod) `<Type returnType><MemberName name> (<{AbstractParameter ","}* parameters>);`, ParseEnv env) 
    = method(\public()[@src=a@\loc], convertType(returnType, env), "<name>", 
    	[convertParameter(p, env) | p <- parameters], [\return(adaptable()[@src=a@\loc])[@src=a@\loc]], emptyExpr()[@src=a@\loc])[@src=a@\loc];

public Declaration convertProxyConstructor(
    a: (ProxyConstructor) `<ArtifactName name> (<{AbstractParameter ","}* parameters>);`, str proxyName, ParseEnv env) {
	
	if ("<name>" != proxyName) {
        throw IllegalConstructorName("\'<name>\' is invalid constructor name", a@\loc);
	}
	
	return constructor([convertParameter(p, env) | p <- parameters], [\return(adaptable()[@src=a@\loc])[@src=a@\loc]], emptyExpr()[@src=a@\loc])[@src=a@\loc];    
}

public Declaration convertArtifact(a: (Artifact) `value <ArtifactName name> {<Declaration* declarations>}`, ParseEnv env) = 
	valueObject("<name>", [convertDeclaration(d, "<name>", "value", env) | d <- declarations], notProxy()[@src=a@\loc])[@src=a@\loc];
    
public Declaration convertArtifact(a: (Artifact) `util <ArtifactName name> {<Declaration* declarations>}`, ParseEnv env) = 
	util("<name>", [convertDeclaration(d, "<name>", "util", env) | d <- declarations])[@src=a@\loc];
    
public Declaration convertArtifact(a: (Artifact) `service <ArtifactName name> {<Declaration* declarations>}`, ParseEnv env) = 
	util("<name>", [convertDeclaration(d, "<name>", "util", env) | d <- declarations])[@src=a@\loc];

public ControllerType convertControllerType(c: (ControllerType) `json-api`) = jsonApi()[@src=c@\loc];
public ControllerType convertControllerType(c: (ControllerType) `rest`) = jsonApi()[@src=c@\loc];

public Route convertRoute(r: (RoutePart) `<Identifier part>`) = routePart("<part>")[@src=r@\loc];
public Route convertRoute(r: (RoutePart) `<RoutePlaceholder placeholder>`) = 
	routeVar(substring("<placeholder>", 1, size("<placeholder>")))[@src=r@\loc];

public str createControllerName(loc file) {
	str name = substring(file.file, 0, size(file.file) - size(file.extension) - 1);
	
	if (/^[A-Z][a-zA-Z]+?Controller$/ !:= name) {
		throw IllegalControllerName("Controller file name <name> does not follow the pattern `^[A-Z][a-zA-Z]+?Controller$`", file);
	}
	
	return name;
}

public Route convertRoute(ro: (Route) `/<{RoutePart "/"}* routes>`) = route([convertRoute(r) | r <- routes])[@src=ro@\loc];

public Declaration convertArtifact(a: (Artifact) `<ControllerType controllerType>controller<Route r>{<Declaration* declarations>}`, ParseEnv env) = 
	controller(
		createControllerName(a@\loc),
		convertControllerType(controllerType), 
		convertRoute(r), 
		[convertDeclaration(d, "", "controller", env) | d <- declarations]
	)[@src=a@\loc];

