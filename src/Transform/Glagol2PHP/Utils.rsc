module Transform::Glagol2PHP::Utils

import Transform::Glagol2PHP::Common;
import Transform::Glagol2PHP::Constructors;
import Transform::Glagol2PHP::Methods;
import Transform::Glagol2PHP::Statements;
import Transform::Glagol2PHP::Properties;
import Transform::Glagol2PHP::ClassItems;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::PHP;
import Config::Reader;

public PhpStmt toPhpClassDef(util(str name, list[Declaration] declarations), <Framework f, ORM orm>)
    = phpClassDef(phpClass(name, {}, phpNoName(), [], toPhpClassItems(declarations, <f, anyORM()>)));