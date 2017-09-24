module Transform::Glagol2PHP::Controllers

import Transform::Env;
import Transform::Glagol2PHP::Annotations;
import Transform::Glagol2PHP::Common;
import Transform::Glagol2PHP::Constructors;
import Transform::Glagol2PHP::Methods;
import Transform::Glagol2PHP::Actions;
import Transform::Glagol2PHP::Statements;
import Transform::Glagol2PHP::Properties;
import Transform::Glagol2PHP::ClassItems;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::PHP;
import Config::Config;

public PhpStmt toPhpClassDef(c: controller(str name, jsonApi(), Route r, list[Declaration] declarations), TransformEnv env)
    = phpClassDef(phpClass(name, {}, phpSomeName(phpName("AbstractController")), [], toPhpClassItems(declarations, env, c))[
        @phpAnnotations=toPhpAnnotations(c, env)
    ]) when usesLumen(env);
