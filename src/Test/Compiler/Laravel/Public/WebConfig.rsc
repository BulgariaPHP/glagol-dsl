module Test::Compiler::Laravel::Public::WebConfig

import Compiler::Laravel::Public::WebConfig;

test bool shouldLaravelCreateWebConfig() =
    createWebConfig() == 
    "\<configuration\>
    '  \<system.webServer\>
    '    \<rewrite\>
    '      \<rules\>
    '        \<rule name=\"Imported Rule 1\" stopProcessing=\"true\"\>
    '          \<match url=\"^(.*)/$\" ignoreCase=\"false\" /\>
    '          \<conditions\>
    '            \<add input=\"{REQUEST_FILENAME}\" matchType=\"IsDirectory\" ignoreCase=\"false\" negate=\"true\" /\>
    '          \</conditions\>
    '          \<action type=\"Redirect\" redirectType=\"Permanent\" url=\"/{R:1}\" /\>
    '        \</rule\>
    '        \<rule name=\"Imported Rule 2\" stopProcessing=\"true\"\>
    '          \<match url=\"^\" ignoreCase=\"false\" /\>
    '          \<conditions\>
    '            \<add input=\"{REQUEST_FILENAME}\" matchType=\"IsDirectory\" ignoreCase=\"false\" negate=\"true\" /\>
    '            \<add input=\"{REQUEST_FILENAME}\" matchType=\"IsFile\" ignoreCase=\"false\" negate=\"true\" /\>
    '          \</conditions\>
    '          \<action type=\"Rewrite\" url=\"index.php\" /\>
    '        \</rule\>
    '      \</rules\>
    '    \</rewrite\>
    '  \</system.webServer\>
    '\</configuration\>";
