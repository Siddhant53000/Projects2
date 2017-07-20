<?php
/**
 * Application_Model_DbTable_Roles
 *
 * @author
 * @version
 */

class Application_Model_DbTable_Roles extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_roles';
    protected $_primary = 'id';
    
    protected $_dependentTables = array('Relroles' => 'Application_Model_DbTable_RelRoles');
}
