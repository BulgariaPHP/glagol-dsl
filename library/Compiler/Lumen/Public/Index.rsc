module Compiler::Lumen::Public::Index

import Syntax::Abstract::PHP;
import Syntax::Abstract::PHP::Helpers;
import Compiler::PHP::Compiler;
import Compiler::PHP::Code;

public str createIndexFile() = implode(toCode(phpScript([
	phpExprstmt(phpAssign(phpVar("app"), phpInclude(
		phpBinaryOperation(phpScalar(phpDirConstant()), phpScalar(phpString("/../bootstrap/app.php")), phpConcat()), 
		phpRequireOnce()))
	),
	phpExprstmt(phpMethodCall(phpVar("app"), phpName(phpName("run")), []))
])));

