module Typechecker::Env

import Syntax::Abstract::Glagol;
import Map;

data Definition
    = field(Declaration d)
    | param(Declaration d)
    | localVar(Statement stmt)
    ;

alias TypeEnv = tuple[
    loc location,
    map[GlagolID, Definition] definitions,
    map[GlagolID, Declaration] imported,
    list[Declaration] ast,
    list[tuple[loc src, str message]] errors
];

public TypeEnv addDefinition(p:property(_, GlagolID name, _, _), TypeEnv env) = 
    addError(p@src, "Cannot redefine \"<name>\". Already defined in <p@src.path> on line <env.definitions[name].d@src.begin.line>.", env) 
    when name in env.definitions;

public TypeEnv addDefinition(p:property(_, GlagolID name, _, _), TypeEnv env) = 
    env[definitions = env.definitions + (name: field(p))] 
    when name notin env.definitions;

public TypeEnv addDefinition(p:param(Type paramType, GlagolID name, Expression defaultValue), TypeEnv env) =
    env[definitions = env.definitions + (name: param(p))];

public TypeEnv addDefinition(d:declare(Type varType, variable(GlagolID name), Statement defaultValue), TypeEnv env) = 
    env[definitions = env.definitions + (name: localVar(d))]
    when name notin env.definitions || (name in env.definitions && field(_) := env.definitions[name]);

public TypeEnv addDefinition(d:declare(Type varType, variable(GlagolID name), Statement defaultValue), TypeEnv env) = 
    addError(d@src, "Cannot decleare \"<name>\". Already decleared in <d@src.path> on line <env.definitions[name].d@src.begin.line>.", env) 
    when name in env.definitions && field(_) !:= env.definitions[name];

public TypeEnv addError(loc src, str message, TypeEnv env) = env[errors = env.errors + <src, message>];

public TypeEnv addErrors(list[tuple[loc, str]] errors, TypeEnv env) = (env | addError(src, message, it) | <loc src, str message> <- errors);

public bool isImported(\import(GlagolID name, Declaration namespace, GlagolID as), TypeEnv env) = 
    (false | true | i <- range(env.imported), i.artifactName == name && i.namespace == namespace);

public bool isInAST(\import(GlagolID name, Declaration namespace, GlagolID as), TypeEnv env) = 
    (false | true | file(_, \module(Declaration ns, _, artifact)) <- env.ast, artifact.name == name && ns == namespace);

public list[Declaration] findArtifact(i:\import(GlagolID name, Declaration namespace, GlagolID as), TypeEnv env) =
	[artifact | file(_, \module(Declaration ns, _, artifact)) <- env.ast, artifact.name == name && ns == namespace];

public bool isEntity(i:\import(GlagolID name, Declaration namespace, GlagolID as), TypeEnv env) = 
    [entity(_, _)] := findArtifact(i, env);
