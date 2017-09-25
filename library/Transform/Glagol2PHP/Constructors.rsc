module Transform::Glagol2PHP::Constructors

import Transform::Env;
import Transform::Glagol2PHP::Annotations;
import Transform::Glagol2PHP::Params;
import Transform::Glagol2PHP::Expressions;
import Transform::Glagol2PHP::Statements;
import Transform::Glagol2PHP::Overriding;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;
import Syntax::Abstract::PHP;
import Syntax::Abstract::PHP::Helpers;
import List;

public PhpClassItem toPhpClassItem(d: constructor(list[Declaration] params, list[Statement] body, emptyExpr()), TransformEnv env) 
    = phpMethod("__construct", {phpPublic()}, false, [toPhpParam(p) | p <- params], 
    	[toPhpStmt(stmt, addDefinitions(params, env)) | stmt <- body], phpNoName())[
    	@phpAnnotations=toPhpAnnotations(d, env)
    ];

public PhpClassItem toPhpClassItem(d: constructor(list[Declaration] params, list[Statement] body, Expression when), TransformEnv env) 
    = phpMethod("__construct", {phpPublic()}, false, [toPhpParam(p) | p <- params], [
        phpIf(toPhpExpr(when, addDefinitions(params, env)), [toPhpStmt(stmt, addDefinitions(params, env)) | stmt <- body], [], phpNoElse())
    ], phpNoName())[
    	@phpAnnotations=toPhpAnnotations(d, env)
    ];
    
public list[Declaration] getNonConstructors(list[Declaration] declarations)
    = [c | c <- declarations, !isConstructor(c)];

public list[Declaration] getConditionalConstructors(list[Declaration] declarations)
    = [c | c <- declarations, constructor(_, _, _) := c];

public list[Declaration] getNonConditionalConstructors(list[Declaration] declarations)
    = [c | c <- declarations, constructor(_, _) !:= c];

public PhpClassItem createConstructor(list[Declaration] declarations, TransformEnv env) = 
    phpMethod("__construct", {phpPublic()}, false, [phpParam("args", phpNoExpr(), phpNoName(), false, true)],
        [phpExprstmt(phpAssign(phpVar(phpName(phpName("overrider"))), phpNew(phpName(phpName("Overrider")), [])))] + 
        [phpExprstmt(createOverrideRule(d, env)) | d <- declarations] +
        [phpNewLine()] +
        [phpExprstmt(phpMethodCall(phpVar("overrider"), phpName(phpName("execute")), [
            phpActualParameter(phpVar("args"), false, true)
        ]))],
    phpNoName())[
    	@phpAnnotations={annotation | d <- declarations, annotation <- toPhpAnnotations(d, env)}
    ]
    when size(declarations) > 1;

public PhpClassItem createConstructor(list[Declaration] declarations, TransformEnv env) = 
	toPhpClassItem(declarations[0], env) when size(declarations) == 1;

public PhpClassItem createDIConstructor(list[Declaration] declarations, TransformEnv env) = 
	phpMethod("__construct", {phpPublic()}, false, 
		[toPhpParam(param(valueType, name, emptyExpr())) | p: property(Type valueType, str name, get(_)) <- declarations],
		[
			phpExprstmt(phpAssign(phpPropertyFetch(phpVar(phpName(phpName("this"))), phpName(phpName(name))), phpVar(phpName(phpName(name))))) | 
			property(Type valueType, str name, get(_)) <- declarations
		],
    phpNoName())[
    	@phpAnnotations={a | d: property(_, _, get(_)) <- declarations, a: annotation("doc", _) <- toPhpAnnotations(d, env)}
    ];
