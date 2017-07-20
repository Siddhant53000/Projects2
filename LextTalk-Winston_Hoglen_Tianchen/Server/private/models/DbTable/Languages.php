<?php
/**
 * Application_Model_DbTable_Languages
 *
 * @author
 * @version
 */

class Application_Model_DbTable_Languages extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_languages';
    protected $_primary = 'language';

    protected $_dependentTables = array(
            'NativesLanguages' => 'Application_Model_DbTable_NativeLanguages',
            'LearningLanguages' => 'Application_Model_DbTable_LearningLanguages',
    );
}
