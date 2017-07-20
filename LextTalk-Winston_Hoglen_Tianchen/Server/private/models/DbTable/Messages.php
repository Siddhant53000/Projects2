<?php
/**
 * Application_Model_DbTable_Messages
 *
 * @author Brais Gabin
 * @version
 */

class Application_Model_DbTable_Messages extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_messages';
    protected $_primary = 'id';

    protected $_referenceMap = array(
            'UserFrom' => array(
                            'columns' => 'from_id',
                            'refTableClass' => 'Application_Model_DbTable_Users',
                            'refColumns' => 'id'
            ),
            'UserTo' => array(
                            'columns' => 'to_id',
                            'refTableClass' => 'Application_Model_DbTable_Users',
                            'refColumns' => 'id'
            ),
            'Event' => array(
                            'columns' => 'event_id',
                            'refTableClass' => 'Application_Model_DbTable_Events',
                            'refColumns' => 'id'
            ),
    );
}
