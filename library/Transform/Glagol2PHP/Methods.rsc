module Transform::Glagol2PHP::Methods

import Transform::Glagol2PHP::Annotations;
import Transform::Glagol2PHP::Statements;
import Transform::Glagol2PHP::Expressions;
import Transform::Glagol2PHP::Params;
import Transform::Glagol2PHP::Overriding;
import Transform::Glagol2PHP::ClassItems;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;
import Syntax::Abstract::PHP;
import List;

public PhpClassItem toPhpClassItem(d: method(modifier, returnType, name, params, body, emptyExpr()), env)
    = phpMethod(
        name, 
        {toPhpModifier(modifier)}, 
        false, 
        [toPhpParam(p) | p <- params], 
        [toPhpStmt(stmt) | stmt <- body], 
        toPhpReturnType(returnType)
    )[
    	@phpAnnotations=toPhpAnnotations(d, env)
    ];

public PhpClassItem toPhpClassItem(d: method(modifier, returnType, name, params, body, Expression when), env)
    = phpMethod(
        name,
        {toPhpModifier(modifier)}, 
        false, 
        [toPhpParam(p) | p <- params], 
        [phpIf(toPhpExpr(when), [toPhpStmt(stmt) | stmt <- body], [], phpNoElse())], 
        toPhpReturnType(returnType)
    )[
    	@phpAnnotations=toPhpAnnotations(d, env)
    ];

public PhpClassItem createMethod(list[Declaration] methods, env)
    = toPhpClassItem(methods[0], env)
    when size(methods) == 1;

public PhpClassItem createMethod(list[Declaration] methods, env) = 
    phpMethod(methods[0].name, {toPhpModifier(methods[0].modifier)}, false, [phpParam("args", phpNoExpr(), phpNoName(), false, true)], 
        [phpExprstmt(phpAssign(phpVar(phpName(phpName("overrider"))), phpNew(phpName(phpName("Overrider")), [])))] + 
        [phpExprstmt(createOverrideRule(m)) | m <- methods] +
        [phpNewLine()] +
        [phpReturn(phpSomeExpr(phpMethodCall(phpVar(phpName(phpName("overrider"))), phpName(phpName("execute")), [
          phpActualParameter(phpVar(phpName(phpName("args"))), false, true)
        ])))], toPhpReturnType(methods[0].returnType))[
    	@phpAnnotations={annotation | m <- methods, annotation <- toPhpAnnotations(m, env)}
    ]
    when size(methods) > 1;

private PhpOptionName toPhpReturnType(voidValue()) = phpNoName();
private PhpOptionName toPhpReturnType(integer()) = phpSomeName(phpName("int"));
private PhpOptionName toPhpReturnType(string()) = phpSomeName(phpName("string"));
private PhpOptionName toPhpReturnType(boolean()) = phpSomeName(phpName("bool"));
private PhpOptionName toPhpReturnType(float()) = phpSomeName(phpName("float"));
private PhpOptionName toPhpReturnType(\list(_)) = phpSomeName(phpName("Vector"));
private PhpOptionName toPhpReturnType(\map(_,_)) = phpSomeName(phpName("Map"));
private PhpOptionName toPhpReturnType(artifact(Name name)) = phpSomeName(phpName(extractName(name)));
private PhpOptionName toPhpReturnType(repository(Name name)) = phpSomeName(phpName(extractName(name) + "Repository"));



private PhpModifier toPhpModifier(\public()) = phpPublic();
private PhpModifier toPhpModifier(\private()) = phpPrivate();
