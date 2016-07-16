module Parser::Converter::Declaration::Method

import Syntax::Abstract::AST;
import Syntax::Concrete::Grammar;
import Parser::Converter::Parameter;
import Parser::Converter::Expression;
import Parser::Converter::Statement;
import Parser::Converter::When;
import Parser::Converter::Type;

public Declaration convertDeclaration(
    (Declaration) `<Type returnType><MemberName name> (<{Parameter ","}* parameters>) { <Statement* body> }`, _) 
    = method(\public(), convertType(returnType), "<name>", [convertParameter(p) | p <- parameters], [convertStmt(stmt) | stmt <- body]);

public Declaration convertDeclaration(
    (Declaration) `<Modifier modifier><Type returnType><MemberName name> (<{Parameter ","}* parameters>) { <Statement* body> }`, _) 
    = method(convertModifier(modifier), convertType(returnType), "<name>", [convertParameter(p) | p <- parameters], [convertStmt(stmt) | stmt <- body]);

public Declaration convertDeclaration(
    (Declaration) `<Type returnType><MemberName name> (<{Parameter ","}* parameters>) { <Statement* body> } <When when>;`, _) 
    = method(\public(), convertType(returnType), "<name>", [convertParameter(p) | p <- parameters], [convertStmt(stmt) | stmt <- body], convertWhen(when));
    
public Declaration convertDeclaration(
    (Declaration) `<Modifier modifier><Type returnType><MemberName name> (<{Parameter ","}* parameters>) { <Statement* body> } <When when>;`, _) 
    = method(convertModifier(modifier), convertType(returnType), "<name>", [convertParameter(p) | p <- parameters], [convertStmt(stmt) | stmt <- body], convertWhen(when));
    
public Declaration convertDeclaration(
    (Declaration) `<Type returnType><MemberName name> (<{Parameter ","}* parameters>) = <Expression expr>;`, _) 
    = method(\public(), convertType(returnType), "<name>", [convertParameter(p) | p <- parameters], [\return(convertExpression(expr))]);

public Declaration convertDeclaration(
    (Declaration) `<Modifier modifier><Type returnType><MemberName name> (<{Parameter ","}* parameters>) = <Expression expr>;`, _) 
    = method(convertModifier(modifier), convertType(returnType), "<name>", [convertParameter(p) | p <- parameters], [\return(convertExpression(expr))]);

public Declaration convertDeclaration(
    (Declaration) `<Type returnType><MemberName name> (<{Parameter ","}* parameters>) = <Expression expr><When when>;`, _) 
    = method(\public(), convertType(returnType), "<name>", [convertParameter(p) | p <- parameters], [\return(convertExpression(expr))], convertWhen(when));

public Declaration convertDeclaration(
    (Declaration) `<Modifier modifier><Type returnType><MemberName name> (<{Parameter ","}* parameters>) = <Expression expr><When when>;`, _) 
    = method(convertModifier(modifier), convertType(returnType), "<name>", [convertParameter(p) | p <- parameters], [\return(convertExpression(expr))], convertWhen(when));
    
private Modifier convertModifier((Modifier) `public`) = \public();
private Modifier convertModifier((Modifier) `private`) = \private();
    
