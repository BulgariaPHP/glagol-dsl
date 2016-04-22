module Test::Parser::Entity::Methods

import Parser::ParseAST;
import Syntax::Abstract::AST;
import Prelude;

test void shouldParseMethodWithoutModifier()
{
	str code = "module Example;
			 'entity User {
			 '    int example() = (23 + 5)*8;
			 '}";
			 
	iprintln(parseModule(code));
}