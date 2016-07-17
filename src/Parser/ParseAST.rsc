module Parser::ParseAST

import Syntax::Abstract::AST;
import Syntax::Concrete::Grammar;
import Parser::ParseCode;
import ParseTree;
import Parser::Converter;

public Declaration parseModule(str code) = buildAST(parseCode(code));
public Declaration parseModule(loc file) = buildAST(parseFile(file));

public Declaration buildAST(start[Test] t) = buildAST(t.top);

public Declaration buildAST((Module) `module <Name name>;<Use* uses>`) = \module("<name>", {convertUse(use) | use <- uses});

public Declaration buildAST((Module) `module <Name name>;<Use* uses><Artifact artifact>`) 
    = \module("<name>", {convertUse(use) | use <- uses}, convertArtifact(artifact));
    
