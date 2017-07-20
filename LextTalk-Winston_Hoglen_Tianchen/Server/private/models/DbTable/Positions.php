<?php
/**
 * Application_Model_DbTable_Positions
 *
 * @author Brais Gabin
 * @version
 */

class Application_Model_DbTable_Positions extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_positions';
    protected $_primary = 'id';

    protected $_referenceMap = array(
            'User' => array(
                            'columns' => 'user_id',
                            'refTableClass' => 'Application_Model_DbTable_Users',
                            'refColumns' => 'id'
            ),
    );
}
