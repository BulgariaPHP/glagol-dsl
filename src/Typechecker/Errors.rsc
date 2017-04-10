module Typechecker::Errors

import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;

public str notImported(a:artifact(GlagolID name)) = "\"<name>\" not imported, but used in <a@src.path> on line <a@src.begin.line>";
public str notImported(r:repository(GlagolID name)) = "\"<name>\" not imported, but used for a repository in <r@src.path> on line <r@src.begin.line>";
public str notImported(r:repository(GlagolID name, _)) = "Entity \"<name>\" not imported in <r@src.path>";
public str notEntity(r:repository(GlagolID name, _)) = "\"<name>\" is not an entity in <r@src.path> on line <r@src.begin.line>";
public str notEntity(r:repository(GlagolID name)) = "\"<name>\" is not an entity in <r@src.path> on line <r@src.begin.line>";
public str notAllowed(Expression expr) = "This type of expression is not allowed in <expr@src.path> on line <expr@src.begin.line>";

public str typeMismatch(Type expected, Type actual) = 
    "Expected <toString(expected)>, but got <toString(actual)> on line <actual@src.begin.line>";
