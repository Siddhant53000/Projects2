<?php
/**
 * Application_Model_DbTable_Sessions
 *
 * @author
 * @version
 */

class Application_Model_DbTable_Sessions extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_sessions';
    protected $_primary = 'id';

    protected $_referenceMap = array(
            'User' => array(
                            'columns' => 'user_id',
                            'refTableClass' => 'Application_Model_DbTable_Users',
                            'refColumns' => 'id'
            ),
    );
}
