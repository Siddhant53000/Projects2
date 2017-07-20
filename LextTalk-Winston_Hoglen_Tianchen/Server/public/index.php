<?php

if(function_exists('lcfirst') === false) {
    function lcfirst($str) {
        $str[0] = strtolower($str[0]);
        return $str;
    }
}



////////////// CONFIGURATION ///////////////////

$username = 'inqbarna';
// ZEND_LIBRARY_PATH points to the Base Zend library directory
defined('ZEND_LIBRARY_PATH')
    || define('ZEND_LIBRARY_PATH', realpath('C:/dev/ZendLibrary'));
// CUSTOM_LIBRARY_PATH points to the Base Custom library directory
defined('CUSTOM_LIBRARY_PATH')
    || define('CUSTOM_LIBRARY_PATH', realpath('C:/dev/lextalk/library'));
// APPLICATION_PATH points to the code for this app
defined('APPLICATION_PATH')
    || define('APPLICATION_PATH', realpath('C:/dev/lextalk/private'));
// PUBLIC_PATH points to this index.php file and all the necessarily public stuff (images, css)
defined('PUBLIC_PATH')
    || define('PUBLIC_PATH',  realpath('C:/dev/lextalk/public'));
// PUBLIC_URL_EXTRAPATH is added to base url (for example http://hit.com gets /backend/ appended) 
//  for public access
defined('PUBLIC_URL_EXTRAPATH')
    || define('PUBLIC_URL_EXTRAPATH', '');
// CONFIG_FILE and APPLICATION_ENV, decide which config file to include
//define('CONFIG_FILE', APPLICATION_PATH.'/configs/application.ini');    
defined('APPLICATION_ENV')
    || define('APPLICATION_ENV', 'development');

    
// Path to webpage code CONFIG PARAM
defined('PRIVATE_APPLICATION_PATH')
    || define('PRIVATE_APPLICATION_PATH', realpath('C:/dev/lextalk/private'));
// Define path to application directory, and path to config tile
define('CONFIG_FILE', PRIVATE_APPLICATION_PATH.'/config.ini');    
defined('APPLICATION_ENV')
    || define('APPLICATION_ENV', (getenv('APPLICATION_ENV') ? getenv('APPLICATION_ENV') : 'development'));


////////////// BOOTSTRAP ///////////////////

// Ensure Zend/ library is on include_path
set_include_path(implode(PATH_SEPARATOR, array(
    ZEND_LIBRARY_PATH,
    get_include_path(),
)));
    
// Create Zend_Application
require_once 'Zend/Application.php';

// Create application, bootstrap, and run
$application = new Zend_Application(
    APPLICATION_ENV,
    CONFIG_FILE
);
$application->bootstrap()->run();
