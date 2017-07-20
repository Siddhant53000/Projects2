<?php
/**
 * Application_Model_DbTable_Users
 *
 * @author Brais Gabin
 * @version
 */

class Application_Model_DbTable_Users extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_users';
    protected $_primary = 'id';

    protected $_dependentTables = array(
            'Relroles' => 'Application_Model_DbTable_RelRoles',
            'Positions' => 'Application_Model_DbTable_Positions',
            'LearningLanguages' => 'Application_Model_DbTable_LearningLanguages',
            'NativeLanguages' => 'Application_Model_DbTable_NativeLanguages',
            'ToMessages' => 'Application_Model_DbTable_Messages',
            'FromMessages' => 'Application_Model_DbTable_Messages',
            'OwnerEvent' => 'Application_Model_DbTable_Events',
            'UsersToEvents' => 'Application_Model_DbTable_UsersToEvents',
    );
}
