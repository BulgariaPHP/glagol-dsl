module Test::Compiler::Lumen::Artisan

import Compiler::Lumen::Artisan;

test bool shouldCreateArtisanFile() =
    createArtisan() == 
    "#!/usr/bin/env php\n" + 
    "\<?php\n" + 
    "require __DIR__ . \"/bootstrap/autoload.php\";\n" + 
    "$app = require_once __DIR__ . \"/bootstrap/app.php\";\n" + 
    "$kernel = $app-\>make(Illuminate\\Contracts\\Console\\Kernel::class);\n" + 
    "$status = $kernel-\>handle($input = new Symfony\\Component\\Console\\Input\\ArgvInput(), new Symfony\\Component\\Console\\Output\\ConsoleOutput());\n" + 
    "$kernel-\>terminate($input, $status);\n" + 
    "exit($status);\n";
