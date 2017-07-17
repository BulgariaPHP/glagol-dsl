module Test::Parser::Controller::Actions

import Parser::ParseAST;
import Syntax::Abstract::Glagol;

test bool parseControllerWithIndexActionWithoutParams() 
{
    str code = "namespace Testing
        'json-api controller /profile {
        '    index {}
        '}
        '";
        
    return parseModule(code, |tmp:///UnknownController.g|).\module == 
    \module(namespace("Testing"), [], controller("UnknownController", jsonApi(), route([routePart("profile")]), [
    	action("index", [], [])
    ]));
}

test bool parseControllerWithIndexActionWithParams() 
{
    str code 
        = "namespace Testing
        'json-api controller /profile {
        '    index (int id) {}
        '}
        '";
        
    return parseModule(code, |tmp:///UnknownController.g|).\module == 
    \module(namespace("Testing"), [], controller("UnknownController", jsonApi(), route([routePart("profile")]), [
    	action("index", [param(integer(), "id", emptyExpr())], [])
    ]));
}


test bool parseControllerWithIndexActionWithParamsAndStmts() 
{
    str code 
        = "namespace Testing
        'json-api controller /profile {
        '    index (int id) {
        '        return new User(id);
        '    }
        '}
        '";
        
    return parseModule(code, |tmp:///UnknownController.g|).\module == 
    \module(namespace("Testing"), [], controller("UnknownController", jsonApi(), route([routePart("profile")]), [
    	action("index", [param(integer(), "id", emptyExpr())], [
    		\return(new(local("User"), [variable("id")]))
    	])
    ]));
}



test bool parseControllerWithIndexActionWithParamsAndStmtsUsingFunctionalStyle() 
{
    str code 
        = "namespace Testing
        'json-api controller /profile {
        '    index (int id) = new User(id);
        '}
        '";
        
    return parseModule(code, |tmp:///UnknownController.g|).\module == 
    \module(namespace("Testing"), [], controller("UnknownController", jsonApi(), route([routePart("profile")]), [
    	action("index", [param(integer(), "id", emptyExpr())], [
    		\return(new(local("User"), [variable("id")]))
    	])
    ]));
}

