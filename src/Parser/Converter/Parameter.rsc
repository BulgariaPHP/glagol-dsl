module Parser::Converter::Parameter

import Syntax::Abstract::Glagol;
import Syntax::Concrete::Grammar;
import Parser::Converter::Type;
import Parser::Converter::Expression;
import Parser::Converter::DefaultValue;
import Parser::Converter::Annotation;

public Declaration convertParameter((AbstractParameter) `<Parameter p>`) = convertParameter(p);
public Declaration convertParameter((AbstractParameter) `<Annotation+ annotations><Parameter p>`) 
    = annotated([convertAnnotation(annotation) | annotation <- annotations], convertParameter(p));

public Declaration convertParameter((Parameter) `<Type paramType> <MemberName name>`) = param(convertType(paramType), "<name>");

public Declaration convertParameter((Parameter) `<Type paramType> <MemberName name> <AssignDefaultValue defaultValue>`) 
    = param(convertType(paramType), "<name>", convertParameterDefaultVal(defaultValue, convertType(paramType)));
