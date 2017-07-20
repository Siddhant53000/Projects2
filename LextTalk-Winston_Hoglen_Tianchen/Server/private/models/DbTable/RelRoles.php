<?php
/**
 * Application_Model_DbTable_RelRoles
 *
 * @author
 * @version
 */

class Application_Model_DbTable_RelRoles extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_rel_roles';

    protected $_referenceMap = array(
            'Role' => array(
                            'columns' => 'role_id',
                            'refTableClass' => 'Application_Model_DbTable_Roles',
                            'refColumns' => 'id'
            ),
            'User' => array(
                            'columns' => 'user_id',
                            'refTableClass' => 'Application_Model_DbTable_Users',
                            'refColumns' => 'id'
            )
    );
}
