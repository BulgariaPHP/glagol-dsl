module Syntax::Concrete::Grammar

extend Syntax::Concrete::Grammar::Keywords;
extend Syntax::Concrete::Grammar::Layout;
extend Syntax::Concrete::Grammar::Lexical;

// Start grammar

start syntax Module
   = \module: ^"module" Name name ";" Imports* imports
   | \module: ^"module" Name name ";" Imports* imports Artifact mainArtifact
   ;

syntax Imports
    = importInternal: "use" ArtifactName target ImportArtifactType artifactType ";"
    | importInternal: "use" ArtifactName target ImportArtifactType artifactType "as" ArtifactName alias ";"
    | importExternal: "use" ArtifactName target ImportArtifactType artifactType "from" Name module ";"
    | importExternal: "use" ArtifactName target ImportArtifactType artifactType "from" Name module "as" ArtifactName alias ";"
    ;

// Artifacts grammar

syntax Artifact
    = entity: EntityAnno* annotations "entity" ArtifactName name "{" EntityDeclarations* declarations "}"
    ;

syntax EntityDeclarations
    = EntityValue
    | EntityRelation
    | Constructor
    | Method
    ;

syntax EntityRelation
    = relation: "relation" RelationDir local ":" RelationDir foreign ArtifactName entity "as" MemberName alias ";"
    | relation: "relation" RelationDir local ":" RelationDir foreign ArtifactName entity "as" MemberName alias "with" "{" {RelProperties ","}* "}" ";"
    ;

syntax EntityValue
    = entityValue: EntityValueAnno* annotations "value" Type type MemberName name ";"
    | entityValue: EntityValueAnno* annotations "value" Type type MemberName name "with" "{" {ValueProperties ","}* "}" ";"
    ;

syntax EntityAnno
    = annoTable: "@table(" "name=" Name name ")"
    | index: "@index(" Name name "," "{" {Name ","}* columns "}" ")"
    ;

syntax EntityValueAnno = annoField: "@field(" {AnnotationFieldKeyPair ","}* pairs ")";

syntax AnnotationFieldKeyPair
    = annoPair: AnnotationFieldKeyIndex key ":" AnnotationFieldKeyValue value
    | annoPair: AnnotationFieldSequenceIndex key ":" Boolean value
    | annoPair: AnnotationFieldTypeIndex key ":" DatabaseType value
    | annoPair: AnnotationFieldSizeIndex key ":" DecimalIntegerLiteral value
    | annoPair: AnnotationFieldScaleIndex key ":" DecimalIntegerLiteral value
    | annoPair: AnnotationFieldColumnIndex key ":" Name value
    ;

// TODO replace Name with lower-case starting alphabetical-chars-only non-terminal
syntax Method
    = method: Modifier modifier Type returnType MemberName name "(" {Parameter ","}* parameters ")" "=" Expression expr When when
    | method: Modifier modifier Type returnType MemberName name "(" {Parameter ","}* parameters ")" "{" Statement* body "}" When when
    ;

syntax When
    = when: "when" Expression when ";"
    | none: ";"
    ;

syntax Constructor
    = constructor: "constructor" "(" {Parameter ","}* parameters ")" MethodBody body When when ConditionalThrow throw ";"
    ;

syntax MethodBody
    = methodBody: "{" Statement* body "}"
    | empty: ()
    ;

syntax When
    = "when" Expression expr
    | none: ()
    ; 

syntax ConditionalThrow
    = conditionalThrow: "throws" ArtifactName exceptionName "(" {DefaultValue ","}* arguments ")" "if" Expression condition
    | emptyDeclaration: ()
    ;

syntax Modifier
    = \public: "public"
    | \public: ()
    | \private: "private"
    ;

syntax DatabaseType
    = integer: "int"
    | \float: "float"
    | \float: "decimal"
    | string: "string"
    | \bool: "bool"
    | \bool: "boolean"
    | \date: "date"
    | \dateTime: "dateTime"
    | \timestamp: "timestamp"
    ;

syntax Type
    = integer: "int"
    | \float: "float"
    | string: "string"
    | \bool: "bool"
    | \bool: "boolean"
    | voidValue: "void"
    | typedArray: Type type "[]"
    > artifactType: ArtifactName name
    ;

syntax Parameter
    = parameter: Type paramType MemberName name ParameterDefaultValue defaultValue
    ;

syntax ParameterDefaultValue
    = defaultValue: "=" DefaultValue defaultValue
    | none: ()
    ;

syntax DefaultValue
    = stringLiteral     : "\"" StringCharacter* string "\""
    | intLiteral        : DecimalIntegerLiteral number
    | floatLiteral      : DeciFloatNumeral number
    | booleanLiteral    : Boolean boolean
    | array             : "[" {DefaultValue ","}* items "]" array
    ;

syntax Statement
    = expression: Expression expression ";"
    | empty: ";"
    ;

syntax Expression
    = bracket \bracket  : "(" Expression expression ")"
    | \array            : "[" {Expression ","}* items "]"
    | negative          : "-" Expression argument
    | stringLiteral     : "\"" StringCharacter* string "\""
    | intLiteral        : DecimalIntegerLiteral number
    | floatLiteral      : DeciFloatNumeral number
    | booleanLiteral    : Boolean boolean
    | variable          : MemberName varName
    > left ( product: Expression lhs "*" () !>> "*" Expression rhs
           | remainder: Expression lhs "%" Expression rhs
           | division: Expression lhs "/" Expression rhs
    )
    > left ( addition   : Expression lhs "+" Expression rhs
           | subtraction: Expression lhs "-" Expression rhs
    )
    > left modulo: Expression lhs "mod" Expression rhs
    > non-assoc ( greaterThanOrEq: Expression lhs "\>=" Expression rhs
                | lessThanOrEq   : Expression lhs "\<=" Expression rhs
                | lessThan       : Expression lhs "\<" !>> "-" Expression rhs
                | greaterThan    : Expression lhs "\>" Expression rhs
    )
    > non-assoc ( equals         : Expression lhs "==" Expression rhs
                | nonEquals      : Expression lhs "!=" Expression rhs
    )
    > left and: Expression lhs "&&" Expression rhs
    > left or: Expression lhs "||" Expression rhs
    > right ifThenElse: Expression condition "?" Expression thenExp ":" Expression elseExp
    ;
