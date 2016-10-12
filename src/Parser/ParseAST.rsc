module Parser::ParseAST

import Syntax::Abstract::Glagol;
import Syntax::Concrete::Grammar;
import Parser::ParseCode;
import ParseTree;
import Parser::Converter;

public Declaration parseModule(str code) = buildAST(parseCode(code));
public Declaration parseModule(loc fileLoc) = file(fileLoc, buildAST(parseFile(fileLoc)));

public Declaration buildAST(start[Module] t) = buildAST(t.top);
