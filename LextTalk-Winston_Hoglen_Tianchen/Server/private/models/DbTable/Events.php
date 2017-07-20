<?php
/**
 * Application_Model_DbTable_Events
 *
 * @author Brais Gabin
 * @version
 */

class Application_Model_DbTable_Events extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_events';
    protected $_primary = 'id';

    protected $_dependentTables = array(
            'Messages' => 'Application_Model_DbTable_Messages',
            'UsersToEvents' => 'Application_Model_DbTable_UsersToEvents',
    );
    
    protected $_referenceMap = array(
            'User' => array(
                            'columns' => 'owner_id',
                            'refTableClass' => 'Application_Model_DbTable_Users',
                            'refColumns' => 'id'
            ),
    );
}
