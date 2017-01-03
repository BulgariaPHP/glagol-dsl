module Parser::Converter::Artifact

import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;
import Syntax::Concrete::Grammar;
import Parser::Converter::Declaration::Constructor;
import Parser::Converter::Declaration::Relation;
import Parser::Converter::Declaration::Method;
import Parser::Converter::Annotation;

public Declaration convertAnnotatedArtifact(a: (AnnotatedArtifact) `<Artifact artifact>`, list[Declaration] imports) = 
	convertArtifact(artifact, imports);
    
public Declaration convertAnnotatedArtifact(a: (AnnotatedArtifact) `<Annotation* annotations><Artifact artifact>`, list[Declaration] imports) = 
	convertArtifact(artifact, imports)[
    	@annotations = convertAnnotations(annotations)
    ];

public Declaration convertArtifact(a: (Artifact) `entity <ArtifactName name> {<Declaration* declarations>}`, list[Declaration] imports) = 
	entity("<name>", [convertDeclaration(d, "<name>", "entity") | d <- declarations])[@src=a@\loc];

public Declaration convertArtifact(a: (Artifact) `repository for <ArtifactName name> {<Declaration* declarations>}`, list[Declaration] imports) {
	if (!isImported("<name>", imports)) {
		throw EntityNotImported("Repository cannot attach to entity \'<name>\': entity not imported", a@\loc);
	}
	
    return repository("<name>", [convertDeclaration(d, "<name>", "repository") | d <- declarations])[@src=a@\loc];
}

public Declaration convertArtifact(a: (Artifact) `value <ArtifactName name> {<Declaration* declarations>}`, list[Declaration] imports) = 
	valueObject("<name>", [convertDeclaration(d, "<name>", "value") | d <- declarations])[@src=a@\loc];
    
public Declaration convertArtifact(a: (Artifact) `util <ArtifactName name> {<Declaration* declarations>}`, list[Declaration] imports) = 
	util("<name>", [convertDeclaration(d, "<name>", "util") | d <- declarations])[@src=a@\loc];
    
public Declaration convertArtifact(a: (Artifact) `service <ArtifactName name> {<Declaration* declarations>}`, list[Declaration] imports) = 
	util("<name>", [convertDeclaration(d, "<name>", "util") | d <- declarations])[@src=a@\loc];

public ControllerType convertControllerType(c: (ControllerType) `json-api`) = jsonApi()[@src=c@\loc];

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

public Declaration convertArtifact(a: (Artifact) `<ControllerType controllerType>controller<{RoutePart "/"}* routes>{<Declaration* declarations>}`, list[Declaration] imports) = 
	controller(
		createControllerName(a@\loc),
		convertControllerType(controllerType), 
		route([convertRoute(r) | r <- routes]), 
		[convertDeclaration(d, "", "controller") | d <- declarations]
	)[@src=a@\loc];
