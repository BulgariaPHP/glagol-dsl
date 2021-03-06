module Test::Parser::Entity::Properties

import Parser::ParseAST;
import Syntax::Abstract::Glagol;

test bool testShouldParseEntityWithProperties()
{
    str code = "namespace Example
               'entity User {
               '    int id;
               '    Date addedOn;
               '	{int, string} aMap = {1: \"asd\"};
               '}";
               
    list[Declaration] expectedValues = [
        property(integer(), "id", emptyExpr()),
        property(artifact(fullName("Date", namespace("Example"), "Date")), "addedOn", emptyExpr()),
        property(\map(integer(), string()), "aMap", \map((integer(1): string("asd"))))
    ];

    return parseModule(code) == \module(namespace("Example"), [], entity("User", expectedValues));
}


test bool testShouldParseEntityWithValuesAndAnnotations()
{
    str code = "namespace Example
               'entity User {
               '    @column({
               '        key: primary,
               '        sequence: true,
               '        type: int,
               '        size: 11,
               '        column: \"id\"
               '    })
               '    float id;
               '
               '    @column({
               '        key: primary,
               '        sequence: true,
               '        size: 11,
               '        column: \"id\"
               '    })
               '    string id;
               '
               '    @column={type: int}
               '    Weight id;
               '}";

    return 
    	parseModule(code) == \module(namespace("Example"), [], entity("User", [
    	   property(float(), "id", emptyExpr()), 
           property(string(), "id", emptyExpr()), 
           property(artifact(fullName("Weight", namespace("Example"), "Weight")), "id", emptyExpr())
	   ])) &&
    	parseModule(code).artifact.declarations[0]@annotations == [
            annotation("column", [
                annotationMap((
                    "key": annotationValPrimary(), 
                    "sequence": annotationVal(true), 
                    "type": annotationVal(integer()), 
                    "size": annotationVal(11), 
                    "column": annotationVal("id")
                ))
            ])
        ] &&
        parseModule(code).artifact.declarations[1]@annotations == [
            annotation("column", [
                annotationMap((
                    "key": annotationValPrimary(), 
                    "sequence": annotationVal(true), 
                    "type": annotationVal(string()), 
                    "size": annotationVal(11), 
                    "column": annotationVal("id")
                ))
            ])
        ] &&
        parseModule(code).artifact.declarations[2]@annotations == [
            annotation("column", [
                annotationMap((
                    "type": annotationVal(integer())
                ))
            ])
        ];
}
