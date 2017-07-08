module Typechecker::Statement

import Typechecker::Env;
import Typechecker::Errors;
import Typechecker::Expression;
import Typechecker::Type;
import Syntax::Abstract::Glagol;

public TypeEnv checkStatements(list[Statement] stmts, t, subroutine, TypeEnv env) =
	(env | checkStatement(stmt, t, subroutine, it) | stmt <- stmts);

public TypeEnv checkStatement(r: \return(Expression expr), t, s, TypeEnv env) = checkReturn(lookupType(expr, env), t, r, env);

public TypeEnv checkStatement(emptyStmt(), _, _, TypeEnv env) = env;

public TypeEnv checkReturn(Type actualType, Type expectedType, Statement r, TypeEnv env) = 
	addError(r@src, "Returning <toString(actualType)>, <toString(expectedType)> expected in <r@src.path> on line <r@src.begin.line>", env)
	when actualType != expectedType;
	
public TypeEnv checkReturn(Type actualType, Type expectedType, Statement r, TypeEnv env) = env;

public TypeEnv checkStatement(block(list[Statement] stmts), t, s, env) = checkStatements(stmts, t, s, env);
public TypeEnv checkStatement(expression(expr), t, s, env) = checkExpression(expr, env);
public TypeEnv checkStatement(ifThen(condition, then), t, s, env) = checkStatement(then, t, s, checkCondition(condition, env));
public TypeEnv checkStatement(ifThenElse(condition, then, \else), t, s, env) = 
	checkStatement(\else, t, s, checkStatement(then, t, s, checkCondition(condition, env)));

public TypeEnv checkStatement(a: assign(assignable, operator, val), t, s, env) = 
	checkAssignType(a, lookupType(assignable, env), lookupType(val, env), checkAssignable(assignable, env));

public TypeEnv checkAssignType(Statement s, Type expectedType, Type actualType, TypeEnv env) =
	addError(s@src, 
		"Cannot assign value of type <toString(actualType)> to a variable of type " + 
		"<toString(expectedType)> in <s@src.path> on line <s@src.begin.line>", env)
	when expectedType != actualType;

public TypeEnv checkAssignType(a: assign(assignable, operator, val), Type expectedType, Type actualType, TypeEnv env) = 
	addError(a@src, "Assignment operator not allowed in <a@src.path> on line <a@src.begin.line>", env)
	when !isOperatorAllowed(expectedType, operator);

public TypeEnv checkAssignType(Statement s, Type expectedType, Type actualType, TypeEnv env) = env;

public bool isOperatorAllowed(Type, defaultAssign()) = true;
public bool isOperatorAllowed(integer(), AssignOperator) = true;
public bool isOperatorAllowed(float(), AssignOperator) = true;
public bool isOperatorAllowed(string(), additionAssign()) = true;
public bool isOperatorAllowed(\list(Type \type), additionAssign()) = true;
public bool isOperatorAllowed(Type, AssignOperator) = false;

public TypeEnv checkAssignable(v: variable(_), TypeEnv env) = checkExpression(v, env);
public TypeEnv checkAssignable(f: fieldAccess(_), TypeEnv env) = checkExpression(f, env);
public TypeEnv checkAssignable(f: fieldAccess(_, _), TypeEnv env) = checkExpression(f, env);
public TypeEnv checkAssignable(a: arrayAccess(_, _), TypeEnv env) = checkExpression(a, env);
public TypeEnv checkAssignable(e, TypeEnv env) = addError(e@src, "Cannot assign value to expression in <e@src.path> on line <e@src.begin.line>", env);

public TypeEnv checkCondition(Expression condition, TypeEnv env) = checkIsBoolean(lookupType(condition, env), condition, checkExpression(condition, env));

public TypeEnv checkIsBoolean(boolean(), _, TypeEnv env) = env;
public TypeEnv checkIsBoolean(_, c, TypeEnv env) = 
	addError(c@src, "Condition does not evaluate to boolean in <c@src.path> on line <c@src.begin.line>", env);

public TypeEnv checkStatement(emptyStmt(), _, _, TypeEnv env) = env;
public TypeEnv checkStatement(p: persist(Expression expr), _, _, TypeEnv env) = checkORMFunction(lookupType(expr, env), p, env);
public TypeEnv checkStatement(p: flush(Expression expr), _, _, TypeEnv env) = checkORMFunction(lookupType(expr, env), p, env);
public TypeEnv checkStatement(p: remove(Expression expr), _, _, TypeEnv env) = checkORMFunction(lookupType(expr, env), p, env);

public TypeEnv checkORMFunction(a: artifact(Name name), p, env) = env when isEntity(a, env);
public TypeEnv checkORMFunction(_, p, env) = 
	addError(p@src, "Only entities can be <stringify(p)> in <p@src.path> on line <p@src.begin.line>", env);

public TypeEnv checkStatement(d: declare(_, Expression varName, _), _,  _, TypeEnv env) = 
	addError(d@src, "Cannot resolve variable name in <d@src.path> on line <d@src.begin.line>", env) 
	when variable(_) !:= varName;

public TypeEnv checkStatement(d: declare(Type varType, variable(GlagolID name), Statement defaultValue), t, s, TypeEnv env) = 
	checkStatement(defaultValue, t, s, checkDeclareType(varType, lookupType(defaultValue, env), name, d, env));

public TypeEnv checkDeclareType(Type expectedType, Type actualType, GlagolID name, d, TypeEnv env) = 
	addError(d@src, 
		"Cannot assign <toString(actualType)> to variable <name> originally defined as <toString(expectedType)> " + 
		"in <d@src.path> on line <d@src.begin.line>", env)
	when expectedType != actualType;
	
public TypeEnv checkDeclareType(Type expectedType, Type actualType, GlagolID name, d, TypeEnv env) = addDefinition(d, env);

public Type lookupType(expression(Expression expr), TypeEnv env) = lookupType(expr, env);
public Type lookupType(assign(_, _, Statement \value), TypeEnv env) = lookupType(\value, env);
public Type lookupType(Statement, TypeEnv env) = unknownType();
	
public TypeEnv checkStatement(d: declare(_, _, _), _, _, TypeEnv env) = addDefinition(d, env);

private str stringify(persist(Expression expr)) = "persisted";
private str stringify(flush(Expression expr)) = "flushed";
private str stringify(remove(Expression expr)) = "removed";

/*
public TypeEnv checkStatement() = ;
public TypeEnv checkStatement() = ;
public TypeEnv checkStatement() = ;
public TypeEnv checkStatement() = ;*/
