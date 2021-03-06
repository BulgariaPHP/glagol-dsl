module Test::Transform::Glagol2PHP::Expressions

import Transform::Env;
import Transform::Glagol2PHP::Expressions;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::PHP;

test bool shouldTransformToScalarIntegerPhpExpr()
    = toPhpExpr(integer(5), newTransformEnv()) == phpScalar(phpInteger(5))
    && toPhpExpr(integer(7), newTransformEnv()) == phpScalar(phpInteger(7))
    && toPhpExpr(integer(2), newTransformEnv()) != phpScalar(phpInteger(1));
    
test bool shouldTransformToScalarFloatPhpExpr()
    = toPhpExpr(float(6.43), newTransformEnv()) == phpScalar(phpFloat(6.43))
    && toPhpExpr(float(6.343), newTransformEnv()) == phpScalar(phpFloat(6.343))
    && toPhpExpr(float(2.0), newTransformEnv()) != phpScalar(phpFloat(3.45));
    
test bool shouldTransformToScalarStringPhpExpr()
    = toPhpExpr(string("some string"), newTransformEnv()) == phpScalar(phpString("some string"))
    && toPhpExpr(string("some string2"), newTransformEnv()) == phpScalar(phpString("some string2"));

test bool shouldTransformToScalarBooleanPhpExpr()
    = toPhpExpr(boolean(true), newTransformEnv()) == phpScalar(phpBoolean(true))
    && toPhpExpr(boolean(false), newTransformEnv()) == phpScalar(phpBoolean(false))
    && toPhpExpr(boolean(false), newTransformEnv()) != phpScalar(phpBoolean(true))
    && toPhpExpr(boolean(true), newTransformEnv()) != phpScalar(phpBoolean(false));
    
test bool shouldTransformToScalarListPhpExpr()
    = toPhpExpr(\list([string("first"), string("second")]), newTransformEnv()) 
    == phpNew(phpName(phpName("Vector")), [phpActualParameter(phpArray([
            phpArrayElement(phpNoExpr(), phpScalar(phpString("first")), false), 
            phpArrayElement(phpNoExpr(), phpScalar(phpString("second")), false)
        ]), false)]) &&
    toPhpExpr(\list([integer(1), integer(2)]), newTransformEnv())
    == phpNew(phpName(phpName("Vector")), [phpActualParameter(phpArray([
            phpArrayElement(phpNoExpr(), phpScalar(phpInteger(1)), false), 
            phpArrayElement(phpNoExpr(), phpScalar(phpInteger(2)), false)
        ]), false)]);

test bool shouldTransformToFetchLocalPropPhpExpr()
    = toPhpExpr(get(artifact(fullName("SomeUtil", namespace("Example"), "SomeUtil"))), newTransformEnv())
    == phpPropertyFetch(phpVar(phpName(phpName("this"))), phpName(phpName("_someUtil")));
    
test bool shouldTransformToFetchArrayDim() = toPhpExpr(arrayAccess(variable("test"), integer(0)), newTransformEnv()) == phpFetchArrayDim(phpVar(phpName(phpName("test"))), phpSomeExpr(phpScalar(phpInteger(0))));
test bool shouldTransformToFetchArrayDim2() = toPhpExpr(arrayAccess(variable("test"), string("dasdasasd")), newTransformEnv()) == phpFetchArrayDim(phpVar(phpName(phpName("test"))), phpSomeExpr(phpScalar(phpString("dasdasasd"))));

test bool shouldTransformToMap() = toPhpExpr(\map((integer(1): string("first"))), newTransformEnv()) == phpStaticCall(phpName(phpName("MapFactory")), phpName(phpName("createFromPairs")), [
    phpActualParameter(phpNew(phpName(phpName("Pair")), [phpActualParameter(phpScalar(phpInteger(1)), false), phpActualParameter(phpScalar(phpString("first")), false)]), false)
]);

@todo="Type check: check that pairs are from the same type further in the sequence"
test bool shouldTransformToMap2() = toPhpExpr(\map((string("key1"): string("val1"), string("key2"): string("val2"))), newTransformEnv()) == phpStaticCall(phpName(phpName("MapFactory")), phpName(phpName("createFromPairs")), [
    phpActualParameter(phpNew(phpName(phpName("Pair")), [phpActualParameter(phpScalar(phpString("key2")), false), phpActualParameter(phpScalar(phpString("val2")), false)]), false),
    phpActualParameter(phpNew(phpName(phpName("Pair")), [phpActualParameter(phpScalar(phpString("key1")), false), phpActualParameter(phpScalar(phpString("val1")), false)]), false)
]);

test bool shouldTransformToVar() = toPhpExpr(variable("myVar"), newTransformEnv()) == phpVar(phpName(phpName("myVar")));

test bool shouldTransformToBracket() = toPhpExpr(\bracket(variable("test")), newTransformEnv()) == phpBracket(phpSomeExpr(phpVar(phpName(phpName("test")))));

test bool shouldTransformToTernary() = toPhpExpr(ifThenElse(greaterThan(integer(3), float(4.5)), integer(3), integer(4)), newTransformEnv()) 
    == phpTernary(phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpGt()), phpSomeExpr(phpScalar(phpInteger(3))), phpScalar(phpInteger(4)));

test bool shouldTrasnformToNew() = toPhpExpr(new(fullName("MyUtil", namespace("Example"), "MyUtil"), []), newTransformEnv()) == phpNew(phpName(phpName("MyUtil")), []);
test bool shouldTrasnformToNewWithArguments()
    = toPhpExpr(new(fullName("MyUtil", namespace("Example"), "MyUtil"), [variable("bla")]), newTransformEnv()) == phpNew(phpName(phpName("MyUtil")), [phpActualParameter(phpVar(phpName(phpName("bla"))), false)]);

test bool shouldTransformToBinaryProductOp() = toPhpExpr(product(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpMul());
test bool shouldTransformToBinaryModOp() = toPhpExpr(remainder(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpMod());
test bool shouldTransformToBinaryDivOp() = toPhpExpr(division(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpDiv());
test bool shouldTransformToBinaryPlusOp() = toPhpExpr(addition(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpPlus());
test bool shouldTransformToBinaryMinusOp() = toPhpExpr(subtraction(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpMinus());
test bool shouldTransformToBinaryGeqOp() = toPhpExpr(greaterThanOrEq(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpGeq());
test bool shouldTransformToBinaryLeqOp() = toPhpExpr(lessThanOrEq(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpLeq());
test bool shouldTransformToBinaryLtOp() = toPhpExpr(lessThan(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpLt());
test bool shouldTransformToBinaryGtOp() = toPhpExpr(greaterThan(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpGt());
test bool shouldTransformToBinaryEqOp() = toPhpExpr(equals(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpIdentical());
test bool shouldTransformToBinaryNonEqOp() = toPhpExpr(nonEquals(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpNotIdentical());
test bool shouldTransformToBinaryAndOp() = toPhpExpr(and(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpLogicalAnd());
test bool shouldTransformToBinaryOrOp() = toPhpExpr(or(integer(3), float(4.5)), newTransformEnv()) == phpBinaryOperation(phpScalar(phpInteger(3)), phpScalar(phpFloat(4.5)), phpLogicalOr());
test bool shouldTransformToUnaryMinusOp() = toPhpExpr(negative(float(4.5)), newTransformEnv()) == phpUnaryOperation(phpScalar(phpFloat(4.5)), phpUnaryMinus());
test bool shouldTransformToBinaryConcatOp() = toPhpExpr(concat(string("test"), string("ing")), newTransformEnv()) == phpBinaryOperation(phpScalar(phpString("test")), phpScalar(phpString("ing")), phpConcat());


test bool shouldTransformToTypeCast() = toPhpExpr(cast(string(), integer(3)), newTransformEnv()) == phpCast(phpString(), phpScalar(phpInteger(3)));

test bool shouldTransformToLocalMethodCall() = 
    toPhpExpr(invoke(symbol("doSomething"), [float(4.3), integer(34)]), newTransformEnv()) ==
    phpMethodCall(phpVar(phpName(phpName("this"))), phpName(phpName("doSomething")), [
        phpActualParameter(phpScalar(phpFloat(4.3)), false),
        phpActualParameter(phpScalar(phpInteger(34)), false)
    ]);
    
// TODO Add transformation: if local variable is not defined, try to access a property (using $this)
test bool shouldTransformToExternalMethodCall() = 
    toPhpExpr(invoke(variable("someService"), symbol("doSomething"), [float(4.3), integer(34)]), newTransformEnv()) ==
    phpMethodCall(phpVar(phpName(phpName("someService"))), phpName(phpName("doSomething")), [
        phpActualParameter(phpScalar(phpFloat(4.3)), false),
        phpActualParameter(phpScalar(phpInteger(34)), false)
    ]);
    
test bool shouldTransformToLocalPropertyFetch() =
    toPhpExpr(fieldAccess(symbol("counter")), newTransformEnv()) ==
    phpPropertyFetch(phpVar(phpName(phpName("this"))), phpName(phpName("counter")));
    
test bool shouldTransformToExternalPropertyFetch() =
    toPhpExpr(fieldAccess(variable("someService"), symbol("counter")), newTransformEnv()) ==
    phpPropertyFetch(phpVar(phpName(phpName("someService"))), phpName(phpName("counter")));

test bool shouldTransformToThis() = toPhpExpr(this(), newTransformEnv()) == phpVar(phpName(phpName("this")));
