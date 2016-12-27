module Test::Parser::Repository::Maps

import Parser::ParseAST;
import Syntax::Abstract::Glagol;

test bool shouldParseMapDeclaration()
{
    str code 
        = "namespace Example;
          'repository for User {
          '     User[] findById(int id) {
          '         {string, int} query = {\"id\": id};
          '         return findOneBy(query);
          '     }
          '}";
    
    return parseModule(code) == \module(namespace("Example"), [], repository("User", [
        method(\public(), \list(artifact("User")), "findById", [
            param(integer(), "id")
        ], [
            declare(\map(string(), integer()), variable("query"), expression(\map((string("id"): variable("id"))))),
            \return(invoke("findOneBy", [variable("query")]))
        ])
    ]));
}
