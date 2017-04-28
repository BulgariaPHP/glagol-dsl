module Test::Compiler::Composer::Dependencies

import Compiler::Composer::Dependencies;
import Syntax::Abstract::Glagol;
import lang::json::ast::JSON;
import Config::Config;

test bool shouldCreateComposerDependenciesUsingLaravelAndDoctrine() = 
    setDependencies(object(()), <object(("glagol": object(("framework": string("laravel"), "orm": string("doctrine"))))), |temp:///|>) == 
    object(("require":object((
        "laravel/framework":string("^5.3"),
        "bulgaria-php/glagol-bridge-laravel":string("^0.1"),
        "bulgaria-php/glagol-php-overriding":string("^0.1"),
        "php":string("^7.1"),
        "laravel-doctrine/orm":string("1.2.*"),
        "bulgaria-php/glagol-php-ds":string("^0.1")
      ))));

