module Test::Transform::Glagol2PHP::Methods::Overriding

extend Transform::Glagol2PHP::Doctrine;

test bool shouldAddOverriderWithRulesWhenTransformingOverridedMethods() = 
    toPhpClassDef(entity("User", [
        method(\public(), voidValue(), "test", [param(integer(), "a")], []),
        method(\public(), voidValue(), "test", [param(string(), "b")], []),
        method(\public(), voidValue(), "test", [param(float(), "c")], [], equals(variable("c"), intLiteral(7)))
    ])) == 
    phpClassDef(phpClass(
        "User", {}, phpNoName(), [], [
            phpMethod("test", {phpPublic()}, false, [phpParam("args", phpNoExpr(), phpNoName(), false, true)], [
                phpExprstmt(phpAssign(phpVar(phpName(phpName("overrider"))), phpNew(phpName(phpName("Overrider")), []))),
                phpExprstmt(phpMethodCall(
                    phpVar(phpName(phpName("overrider"))), phpName(phpName("override")), [
                        phpActualParameter(phpClosure([], [phpParam("a", phpNoExpr(), phpSomeName(phpName("int")), false, false)], [], false, false), false),
                        phpActualParameter(phpNew(phpName(phpName("Parameter\\Integer")), []), false)
                    ]
                )),
                phpExprstmt(phpMethodCall(
                    phpVar(phpName(phpName("overrider"))), phpName(phpName("override")), [
                        phpActualParameter(phpClosure([], [phpParam("b", phpNoExpr(), phpSomeName(phpName("string")), false, false)], [], false, false), false),
                        phpActualParameter(phpNew(phpName(phpName("Parameter\\Str")), []), false)
                    ]
                )),
                phpExprstmt(phpMethodCall(phpMethodCall(
                    phpVar(phpName(phpName("overrider"))), 
                    phpName(phpName("override")), [
                        phpActualParameter(phpClosure([], [phpParam("c", phpNoExpr(), phpSomeName(phpName("float")), false, false)], [], false, false), false),
                        phpActualParameter(phpNew(phpName(phpName("Parameter\\Real")), []), false)
                    ]
                ), phpName(phpName("when")), [
                    phpActualParameter(phpClosure([
                        phpReturn(phpSomeExpr(phpBinaryOperation(phpVar(phpName(phpName("c"))), phpScalar(phpInteger(7)), phpIdentical())))
                    ], [phpParam("c", phpNoExpr(), phpSomeName(phpName("float")), false, false)], [], false, false), false)
                ]))
            ], phpNoName())
        ]
    ));