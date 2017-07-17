module Typechecker::Method

import Typechecker::Env;
import Typechecker::Errors;
import Typechecker::Type;
import Typechecker::Param;
import Typechecker::Method::Guard;
import Typechecker::Method::Body;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;
import List;

public TypeEnv checkMethod(c: constructor(_, _, _), Declaration parent, TypeEnv env) = 
	addError(c, "Constructor has duplicating signature", env)
	when hasDuplicates(c, parent.declarations);

public TypeEnv checkMethod(m: method(_, _, GlagolID name, _, _, _), Declaration parent, TypeEnv env) = 
	addError(m, "Method <name> has been defined more than once with a duplicating signature", env)
	when hasDuplicates(m, parent.declarations);

public TypeEnv checkMethod(m: method(\mod, _, GlagolID name, _, _, _), Declaration parent, TypeEnv env) = 
	addError(m,
		"Method <name> is defined more than once with different access modifiers", env)
	when isDefinedWithDifferentAccessModifier(m, parent.declarations);

public TypeEnv checkMethod(m: method(_, t, GlagolID name, _, _, _), Declaration parent, TypeEnv env) = 
	addError(m,
		"Method <name> is defined more than once with different return types", env)
	when isDefinedWithDifferentReturnTypes(m, parent.declarations);

public TypeEnv checkMethod(m: method(_, Type t, _, list[Declaration] params, list[Statement] body, Expression guard), Declaration parent, TypeEnv env) =
	checkBody(body, t, m, parent, checkGuard(guard, checkParams(params, env)));
	
public TypeEnv checkMethod(c: constructor(list[Declaration] params, list[Statement] body, Expression guard), Declaration parent, TypeEnv env) =
	checkBody(body, voidValue(), c, parent, checkGuard(guard, checkParams(params, env)));

private bool hasDuplicates(method(_, _, n, p, _, g), list[Declaration] declarations) = 
	size([d | d: method(_, _, n, p, _, g) <- declarations]) > 1;
	
private bool hasDuplicates(constructor(p, _, g), list[Declaration] declarations) = 
	size([d | d: constructor(p, _, g) <- declarations]) > 1;

private bool isDefinedWithDifferentAccessModifier(method(originalMod, _, n, _, _, _), list[Declaration] declarations) =
	size([d | d: method(modifier, _, n, _, _, _) <- declarations, modifier != originalMod]) > 0;

private bool isDefinedWithDifferentReturnTypes(method(_, originalReturnType, n, _, _, _), list[Declaration] declarations) =
	size([d | d: method(_, returnType, n, _, _, _) <- declarations, returnType != originalReturnType]) > 0;


