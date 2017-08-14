module Test::Compiler::PHP::Properties

import Compiler::PHP::Properties;
import Syntax::Abstract::PHP;

test bool shoudCompilePropertyWithoutAnootationsAndNoDefaultValue() = 
	toCode(phpProperty({phpPrivate()}, [phpProperty("test", phpNoExpr())]), 0) ==
	"\nprivate $test;\n";

test bool shoudCompilePropertyWithDocAnootationAndNoDefaultValue() = 
	toCode(phpProperty({phpPrivate()}, [phpProperty("test", phpNoExpr())])[@phpAnnotations={
		phpAnnotation("doc", phpAnnotationVal("This is a doc"))
	}], 0) ==
	"\n/**\n * This is a doc\n */\nprivate $test;\n";

test bool shoudCompilePropertyWithDocAndIDAnootationsAndNoDefaultValue() = 
	toCode(phpProperty({phpPrivate()}, [phpProperty("test", phpNoExpr())])[@phpAnnotations={
		phpAnnotation("doc", phpAnnotationVal("This is a doc")),
		phpAnnotation("ORM\\Id")
	}], 0) ==
	"\n/**\n * This is a doc\n *\n * @ORM\\Id\n */\nprivate $test;\n";

test bool shoudCompilePropertyWithDocAndVarTypeAnootationsAndNoDefaultValue() = 
	toCode(phpProperty({phpPrivate()}, [phpProperty("test", phpNoExpr())])[@phpAnnotations={
		phpAnnotation("doc", phpAnnotationVal("This is a doc")),
		phpAnnotation("var", phpAnnotationVal("integer"))
	}], 0) ==
	"\n/**\n * This is a doc\n *\n * @var integer\n */\nprivate $test;\n";

test bool shoudCompilePropertyWithNoAnnotationsAndDefaultValue() = 
	toCode(phpProperty({phpPrivate()}, [phpProperty("test", phpSomeExpr(
		phpScalar(phpInteger(23))
	))]), 0) ==
	"\nprivate $test = 23;\n";
