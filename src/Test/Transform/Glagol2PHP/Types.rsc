module Test::Transform::Glagol2PHP::Types

import Syntax::Abstract::Glagol;
import Syntax::Abstract::PHP;
import Transform::Glagol2PHP::Types;

test bool shouldTransformIntegerTypeToPhpTypeName()
    = toPhpTypeName(integer()) == phpName("int");

test bool shouldTransformStringTypeToPhpTypeName()
    = toPhpTypeName(string()) == phpName("string");

test bool shouldTransformFloatTypeToPhpTypeName()
    = toPhpTypeName(float()) == phpName("float");
    
test bool shouldTransformBooleanTypeToPhpTypeName()
    = toPhpTypeName(boolean()) == phpName("bool");
    
test bool shouldTransformIntTypedListToPhpTypeName()
    = toPhpTypeName(typedList(integer())) == phpName("array");
    
test bool shouldTransformStringTypedListToPhpTypeName()
    = toPhpTypeName(typedList(string())) == phpName("array");
    
test bool shouldTransformTypedMapToPhpTypeName()
    = toPhpTypeName(typedMap(string(), integer())) == phpName("array");
    
test bool shouldTransformTypedMapTwoToPhpTypeName()
    = toPhpTypeName(typedMap(string(), string())) == phpName("array");
    
test bool shouldTransformArtifactTypeToPhpTypeName()
    = toPhpTypeName(artifactType("SomeUtil")) == phpName("SomeUtil");
    
test bool shouldTransformRepositoryTypeToPhpTypeName()
    = toPhpTypeName(repositoryType("User")) == phpName("UserRepository");
    