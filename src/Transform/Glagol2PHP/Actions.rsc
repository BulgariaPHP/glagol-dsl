module Transform::Glagol2PHP::Actions

import Transform::Glagol2PHP::Annotations;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;
import Syntax::Abstract::PHP;
import Syntax::Abstract::PHP::Helpers;
import Config::Config;
import Transform::Glagol2PHP::Statements;
import Transform::Glagol2PHP::Params;
import String;

public PhpClassItem toPhpClassItem(a: action(str name, list[Declaration] params, list[Statement] body), env: <f: laravel(), ORM orm>)
    = phpMethod(
        name, 
        {phpPublic()}, 
        false, 
        toActionParams(params, name), 
        createInitializers(params, name) +
        [fixReturn(toPhpStmt(stmt), name) | stmt <- body], 
        phpNoName()
    )[
    	@phpAnnotations=toPhpAnnotations(a, env)
    ];

private list[PhpParam] toActionParams(list[Declaration] params, _) {
    list[PhpParam] phpParams;
    
    phpParams = for (p <- params) {
        if (hasAnnotation(p, "autofind")) {
            append toPhpParam(param(integer(), "id"));
        } else if (!hasAnnotation(p, "autofill")) {
            append toPhpParam(p);
        }
    }
    
    return phpParams;
}
 
private list[PhpParam] toActionParams(list[Declaration] params, _) = [toPhpParam(p) | p <- params]; 

private PhpStmt fixReturn(phpReturn(phpSomeExpr(PhpExpr expr)), "index") = phpReturn(phpSomeExpr(
    phpStaticCall(phpName(phpName("CollectionExtractor")), phpName(phpName("extract")), [
        phpActualParameter(expr, false)
    ])
));

private PhpStmt fixReturn(phpReturn(phpSomeExpr(PhpExpr expr)), /show|store|update|create|edit/) = phpReturn(phpSomeExpr(
    phpStaticCall(phpName(phpName("EntityExtractor")), phpName(phpName("extract")), [
        phpActualParameter(expr, false)
    ])
));

private PhpStmt fixReturn(PhpStmt stmt, _) = stmt;

private list[PhpStmt] createInitializers(list[Declaration] params, _) {

    list[PhpStmt] stmts = [];

    bool hasAutofind = false;

    for (p <- params, hasAnnotation(p, "autofind")) {
        hasAutofind = true;
        stmts += phpExprstmt(
            phpAssign(phpVar(p.name), phpMethodCall(phpPropertyFetch(phpVar("this"), phpName(phpName(
                toLowerCase(p.name) + "s"
            ))), phpName(phpName("find")), [
                phpActualParameter(phpVar("id"), false)
            ]))
        );
    }
    
    for (p <- params, hasAnnotation(p, "autofill")) {
        if (hasAutofind) 
            stmts += phpExprstmt(
                phpStaticCall(phpName(phpName("EntityInflator")), phpName(phpName("inflate")), [
                    phpActualParameter(phpVar(p.name), false),
                    phpActualParameter(phpMethodCall(phpPropertyFetch(
                        phpStaticCall(phpName(phpName("\\Request")), phpName(phpName("getFacadeRoot")), []), 
                        phpName(phpName("request"))
                    ), phpName(phpName("all")), []), false)
                ])
            );
        else if (artifact(str artifactName) := p.paramType)
            stmts += [
                phpExprstmt(phpAssign(phpVar("reflection"), phpNew(phpName(phpName("\\ReflectionClass")), [
                    phpActualParameter(phpFetchClassConst(phpName(phpName(artifactName)), "class"), false)
                ]))),
                phpExprstmt(phpAssign(phpVar(p.name), phpMethodCall(phpVar("reflection"), phpName(phpName(
                    "newInstanceWithoutConstructor"
                )), []))),
                phpExprstmt(
                    phpStaticCall(phpName(phpName("EntityInflator")), phpName(phpName("inflate")), [
                        phpActualParameter(phpVar(p.name), false),
                        phpActualParameter(phpMethodCall(phpPropertyFetch(
                            phpStaticCall(phpName(phpName("\\Request")), phpName(phpName("getFacadeRoot")), []), 
                            phpName(phpName("request"))
                        ), phpName(phpName("all")), []), false)
                    ])
                )
            ];
    }
    
    return stmts;
}
