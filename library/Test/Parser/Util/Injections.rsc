module Test::Parser::Util::Injections

import Parser::ParseAST;
import Syntax::Abstract::Glagol;
import IO;

test bool canParseRepositoryInjection() 
{
    str code
        = "namespace Test
          'service UserCreator {
          '    repository\<User\> userRepository = get repository\<User\>;
          '}";
    
    return parseModule(code) ==
        \module(namespace("Test"), [], util("UserCreator", [
            property(repository(unresolvedName("User")), "userRepository", {}, get(repository(unresolvedName("User"))))
        ]));
}

test bool canParseUtilRepositoryInjection() 
{
    str code
        = "namespace Test
          'service UserCreator {
          '    repository\<User\> userRepository = get repository\<User\>;
          '}";
    
    return parseModule(code) ==
        \module(namespace("Test"), [], util("UserCreator", [
            property(repository(unresolvedName("User")), "userRepository", {}, get(repository(unresolvedName("User"))))
        ]));
}   

test bool canUseRepositorySelfie() 
{
    str code
        = "namespace Test
          'service UserCreator {
          '    repository\<User\> userRepository = get selfie;
          '}";
    
    return parseModule(code) ==
        \module(namespace("Test"), [], util("UserCreator", [
            property(repository(unresolvedName("User")), "userRepository", {}, get(repository(unresolvedName("User"))))
        ]));
}

test bool canUseRepositorySelfieAsParamDefaultValue() 
{
    str code
        = "namespace Test
          'service UserCreator {
          '    public void make(repository\<User\> userRepository = get selfie) { }
          '}";
    
    return parseModule(code) ==
        \module(namespace("Test"), [], util("UserCreator", [
            method(\public(), voidValue(), "make", [
                param(repository(unresolvedName("User")), "userRepository", get(repository(unresolvedName("User"))))
            ], [], emptyExpr())
        ]));
}

test bool canUseRepositoryAssocArtifactInExpression() 
{
    str code
        = "namespace Test
          'service UserCreator {
          '    public void blah() {
          '        get repository\<User\>;
          '        get repository\<User\>.findOneById(1);
          '    }
          '}";
    
    return parseModule(code) ==
        \module(namespace("Test"), [], util("UserCreator", [
            method(\public(), voidValue(), "blah", [], [
                expression(get(repository(unresolvedName("User")))),
                expression(invoke(get(repository(unresolvedName("User"))), "findOneById", [integer(1)]))
            ], emptyExpr())
        ]));
}

test bool canCreateNewServiceAsAPropertyDefaultValue() 
{
    str code
        = "namespace Test
          'service UserCreator {
          '    UserService userService = new UserService();
          '}";
    
    return parseModule(code) ==
        \module(namespace("Test"), [], util("UserCreator", [
            property(artifact(unresolvedName("UserService")), "userService", {}, new(unresolvedName("UserService"), []))
        ]));
}
