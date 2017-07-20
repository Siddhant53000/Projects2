<?php
/**
 * Application_Model_DbTable_LearningLanguages
 *
 * @author Brais Gabin
 * @version
 */

class Application_Model_DbTable_LearningLanguages extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_learning_languages';

    protected $_referenceMap = array(
            'User' => array(
                            'columns' => 'user_id',
                            'refTableClass' => 'Application_Model_DbTable_Users',
                            'refColumns' => 'id'
            ),
            'Language' => array(
                            'columns' => 'language_id',
                            'refTableClass' => 'Application_Model_DbTable_Languages',
                            'refColumns' => 'language'
            ),
    );
}
