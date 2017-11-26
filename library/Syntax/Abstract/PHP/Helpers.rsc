module Syntax::Abstract::PHP::Helpers

import Syntax::Abstract::PHP;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;

public PhpExpr phpVar(str name) = phpVar(phpName(phpName(name)));

public PhpStmt phpDeclareStrict() = phpDeclare([phpDeclaration("strict_types", phpScalar(phpInteger(1)))], []);

public PhpExpr phpNew(str name, list[PhpActualParameter] parameters) = phpNew(phpName(phpName(name)), parameters);

public PhpExpr phpCall(str name, list[PhpActualParameter] parameters) = phpCall(phpName(phpName(name)), parameters);

public PhpParam phpParam(str paramName) = phpParam(paramName, phpNoExpr(), phpNoName(), false, false);

public PhpOptionName makeOptional(phpSomeName(phpName(str \type))) = phpSomeName(phpName("?<\type>"));
