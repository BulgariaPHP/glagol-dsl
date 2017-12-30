module Transform::Glagol2PHP::Repositories

import Transform::Env;
import Transform::OriginAnnotator;
import Transform::Glagol2PHP::Annotations;
import Transform::Glagol2PHP::Common;
import Transform::Glagol2PHP::Constructors;
import Transform::Glagol2PHP::Methods;
import Transform::Glagol2PHP::Statements;
import Transform::Glagol2PHP::Properties;
import Transform::Glagol2PHP::ClassItems;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::PHP;
import Config::Config;

public PhpStmt toPhpClassDef(r: repository(str name, list[Declaration] declarations), TransformEnv env)
    = origin(phpClassDef(origin(phpClass("<name>Repository", {}, origin(phpSomeName(phpName("EntityRepository")), r), [], 
    		toPhpClassItems(declarations, env))[
        @phpAnnotations=toPhpAnnotations(r, env)
    ], r)), r);
