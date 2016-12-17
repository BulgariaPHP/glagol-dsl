module Test::Transform::Glagol2PHP::Common

import Transform::Glagol2PHP::Common;
import Syntax::Abstract::Glagol;

test bool shouldMakeStringFromNamespaceChainUsingDelimiter() 
    = "Some::Example::Namespace" == namespaceToString(namespace("Some", namespace("Example", namespace("Namespace"))), "::");

test bool shouldMakeStringFromNamespaceChainUsingAltDelimiter() 
    = "Another\\Example\\Namespace" == namespaceToString(namespace("Another", namespace("Example", namespace("Namespace"))), "\\");

test bool shouldMakeFilenameFromNamespaceAndEntity()
    = "Some/Example/Entity/Test.php" == makeFilename(namespace("Some", namespace("Example", namespace("Entity"))), entity("Test", []));

test bool shouldMakeFilenameFromNamespaceAndAnnotatedEntity()
    = "Some/Example/Entity/Test.php" == makeFilename(namespace(
    	"Some", namespace("Example", namespace("Entity"))), annotated([], entity("Test", [])));

test bool shouldMakeFilenameFromNamespaceAndUtil()
    = "Some/Example/Util/Test.php" == makeFilename(namespace(
    	"Some", namespace("Example", namespace("Util"))), util("Test", []));

test bool shouldMakeFilenameFromNamespaceAndValueObject()
    = "Some/Example/VO/Test.php" == makeFilename(namespace(
    	"Some", namespace("Example", namespace("VO"))), valueObject("Test", []));

test bool shouldMakeFilenameFromNamespaceAndRepository()
    = "Some/Example/Repository/TestRepository.php" == makeFilename(namespace(
    	"Some", namespace("Example", namespace("Repository"))), repository("Test", []));

    
