module Compiler::Composer::Dependencies::Framework

import Config::Config;
import lang::json::IO;
import lang::json::ast::JSON;

public map[str, JSON] getFrameworkDependencies(lumen()) = (
	"laravel/lumen-framework": string("5.4.*"),
	"vlucas/phpdotenv": string("~2.2"),
	"bulgaria-php/glagol-bridge-lumen": string("^0.1")
);
