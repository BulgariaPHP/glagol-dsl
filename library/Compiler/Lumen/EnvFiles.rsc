module Compiler::Lumen::EnvFiles

import Config::Config;
import Config::Reader;
import Compiler::PHP::Compiler;
import Compiler::Lumen::Bootstrap::App;
import Compiler::Lumen::Public::Index;
import Compiler::Lumen::Public::Htaccess;
import Compiler::Lumen::Config::Doctrine;
import Compiler::Lumen::Config::Database;
import Compiler::Lumen::Routes::Api;
import Compiler::Lumen::Routes::Console;
import Compiler::Lumen::Server;
import Compiler::Lumen::Artisan;
import Syntax::Abstract::Glagol;
import Syntax::Abstract::Glagol::Helpers;
import Syntax::Abstract::PHP;
import Syntax::Abstract::PHP::Helpers;
import IO;

public map[loc, str] generateFrameworkFiles(lumen(), Config config, list[Declaration] ast) = (
	|file:///| + "bootstrap/app.php": createAppFile(getORM(config), ast),
    |file:///| + "bootstrap/cache/.gitignore": "",
	|file:///| + "public/index.php": createIndexFile(),
	|file:///| + "public/.htaccess": createHtaccess(),
    |file:///| + "artisan": createArtisan(),
    |file:///| + "config/doctrine.php": createDoctrineConfig(),
    |file:///| + "config/database.php": createDatabaseConfig(),
    |file:///| + "routes/api.php": createRoutesApi(ast),
    |file:///| + "routes/console.php": createRoutesConsole(),
    |file:///| + "server.php": createServerFile()
) + getRepositoryProviders(getORM(config), config, ast) + getCustomTypes(ast, getORM(config));

private map[loc, str] getCustomTypes(list[Declaration] ast, doctrine()) =
	(|file:///| + "app/Types/<namespaceToString(ns)><name>Type.php": 
    	createType(e) | \file(_, e: \module(ns, _, valueObject(str name, _))) <- ast);

private str createType(m: \module(ns, _, valueObject(str name, _))) = toCode(
	phpScript([
        phpNamespace(
            phpSomeName(phpName("App\\Types")),
            [
                phpUse({
                    phpUse(phpName("Doctrine\\DBAL\\Types\\Type"), phpNoName()),
                    phpUse(phpName("Doctrine\\DBAL\\Platforms\\AbstractPlatform"), phpNoName()),
                    phpUse(phpName(namespaceToString(ns, "\\") + "\\<name>"), phpNoName())
                }),
                phpClassDef(phpClass("<name>Type", {}, phpSomeName(phpName("Type")), [], [
                    //phpMethod("register", {phpPublic()}, false, [], [], phpNoName())
                ]))
            ]
        )
    ])
);

private map[loc, str] getRepositoryProviders(doctrine(), Config config, list[Declaration] ast) = 
    (|file:///| + "app/Provider/<namespaceToString(ns, "/")>/<name>RepositoryProvider.php": 
    	createProvider(doctrine(), e) | \file(_, e: \module(ns, _, repository(str name, _))) <- ast);

private str createProvider(doctrine(), m: \module(ns, _, repository(str name, list[Declaration] declarations))) = 
    toCode(phpScript([
        phpNamespace(
            phpSomeName(phpName("App\\Provider\\<namespaceToString(ns, "\\")>")),
            [
                phpUse({
                    phpUse(phpName("Illuminate\\Support\\ServiceProvider"), phpNoName()),
                    phpUse(phpName(namespaceToString(ns, "\\") + "\\<name>Repository"), phpNoName())
                }),
                phpClassDef(phpClass("<name>RepositoryProvider", {}, phpSomeName(phpName("ServiceProvider")), [], [
                    phpMethod("register", {phpPublic()}, false, [], [
                        phpExprstmt(phpMethodCall(phpPropertyFetch(phpVar("this"), phpName(phpName("app"))), phpName(phpName("bind")), [
                            phpActualParameter(phpFetchClassConst(phpName(phpName("<name>Repository")), "class"), false),
                            phpActualParameter(phpClosure([
                                phpExprstmt(phpAssign(phpVar("em"), phpMethodCall(phpVar("app"), phpName(phpName("make")), [
                                    phpActualParameter(phpScalar(phpString("em")), false)
                                ]))),
                                phpExprstmt(phpAssign(phpVar("meta"), phpMethodCall(
                                    phpVar("em"),
                                    phpName(phpName("getClassMetadata")),
                                    [
                                        phpActualParameter(phpFetchClassConst(
                                        phpName(phpName("<getTargetEntityWithNamespace(m)>")),
                                        "class"), false)
                                    ]
                                ))),
                                phpReturn(phpSomeExpr(phpNew(phpName(phpName("<name>Repository")), [
                                    phpActualParameter(phpVar("em"), false),
                                    phpActualParameter(phpVar("meta"), false)
                                ])))
                            ], [phpParam("app", phpNoExpr(), phpNoName(), false, false)], [], false, false), false)
                        ]))
                    ], phpNoName())
                ]))
            ]
        )
    ]));

private str getTargetEntityWithNamespace(\module(Declaration ns, list[Declaration] imports, repository(str name, _))) {
    for (a: \import(str realName, Declaration namespace, str as) <- imports, as == name) {
        return "\\" + namespaceToString(namespace, "\\") + "\\<realName>";
    }
    
    return "\\" + namespaceToString(ns, "\\") + "\\<name>";
}
