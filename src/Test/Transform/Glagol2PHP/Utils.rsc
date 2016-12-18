module Test::Transform::Glagol2PHP::Utils

import Transform::Glagol2PHP::ClassItems;
import Transform::Glagol2PHP::Utils;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::PHP;
import Config::Reader;

test bool shouldTransformToUtilPhpClassDefStmt() = 
	toPhpClassDef(util("User", [
		property(string(), "a property", {})
	]), <anyFramework(), anyORM()>) ==
	phpClassDef(phpClass("User", {}, phpNoName(), [], [
		phpProperty(
        {phpPrivate()},
        [phpProperty(
            "a property",
            phpNoExpr())])
	]));

test bool shouldTransformAnnotatedUtilToUtilPhpClassDefStmt() = 
	toPhpClassDef(util("User", [])[@annotations=[]], <anyFramework(), anyORM()>) ==
	phpClassDef(phpClass("User", {}, phpNoName(), [], [])) &&
	toPhpClassDef(util("User", [])[@annotations=[annotation("doc", [annotationVal("This is a doc")])]], <anyFramework(), anyORM()>).classDef@phpAnnotations ==
		{phpAnnotation("doc", phpAnnotationVal("This is a doc"))};

