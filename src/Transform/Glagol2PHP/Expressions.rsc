module Transform::Glagol2PHP::Expressions

import Syntax::Abstract::Glagol;
import Syntax::Abstract::PHP;
import Utils::String;

// literals
public PhpExpr toPhpExpr(intLiteral(int i)) = phpScalar(phpInteger(i));
public PhpExpr toPhpExpr(floatLiteral(real r)) = phpScalar(phpFloat(r));
public PhpExpr toPhpExpr(strLiteral(str s)) = phpScalar(phpString(s));
public PhpExpr toPhpExpr(boolLiteral(bool b)) = phpScalar(phpBoolean(b));

// arrays
public PhpExpr toPhpExpr(\list(list[Expression] items)) 
    = phpNew(phpName(phpName("Vector")), [phpActualParameter(phpArray([phpArrayElement(phpNoExpr(), toPhpExpr(i), false) | i <- items]), false)]);

public PhpExpr toPhpExpr(arrayAccess(Expression variable, Expression arrayIndexKey)) = phpFetchArrayDim(toPhpExpr(variable), phpSomeExpr(toPhpExpr(arrayIndexKey)));

public PhpExpr toPhpExpr(\map(map[Expression key, Expression \value] m)) = 
    phpStaticCall(phpName(phpName("MapFactory")), phpName(phpName("createFromPairs")), [
        phpActualParameter(phpNew(phpName(phpName("Pair")), [phpActualParameter(toPhpExpr(k), false), phpActualParameter(toPhpExpr(m[k]), false)]), false) | k <- m
    ]);

public PhpExpr toPhpExpr(get(artifactType(str name))) 
    = phpPropertyFetch(phpVar(phpName(phpName("this"))), phpName(phpName(toLowerCaseFirstChar(name))));

public PhpExpr toPhpExpr(variable(str name)) = phpVar(phpName(phpName(name)));

// Logical binary operations
public PhpExpr toPhpExpr(equals(Expression l, Expression r)) = phpBinaryOperation(toPhpExpr(l), toPhpExpr(r), phpIdentical());
public PhpExpr toPhpExpr(greaterThan(Expression l, Expression r)) = phpBinaryOperation(toPhpExpr(l), toPhpExpr(r), phpGt());
public PhpExpr toPhpExpr(product(Expression lhs, Expression rhs)) = phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpMul());
public PhpExpr toPhpExpr(remainder(Expression lhs, Expression rhs)) = phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpMod());
public PhpExpr toPhpExpr(division(Expression lhs, Expression rhs)) = phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpDiv());
public PhpExpr toPhpExpr(addition(Expression lhs, Expression rhs)) = phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpPlus());
public PhpExpr toPhpExpr(subtraction(Expression lhs, Expression rhs)) = phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpMinus());
public PhpExpr toPhpExpr(\bracket(Expression e)) = phpBracket(phpSomeExpr(toPhpExpr(e)));
public PhpExpr toPhpExpr(greaterThanOrEq(Expression lhs, Expression rhs)) = phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpGeq());
public PhpExpr toPhpExpr(lessThanOrEq(Expression lhs, Expression rhs)) = phpBinaryOperation(toPhpExpr(lhs), toPhpExpr(rhs), phpLeq());
