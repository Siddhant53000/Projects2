<?php
/**
 * Application_Model_DbTable_UsersToEvents
 *
 * @author
 * @version
 */

class Application_Model_DbTable_UsersToEvents extends Zend_Db_Table_Abstract {
    protected $_name = 'lex_users_to_events';

    protected $_referenceMap = array(
            'User' => array(
                            'columns' => 'user_id',
                            'refTableClass' => 'Application_Model_DbTable_Users',
                            'refColumns' => 'id'
            ),
            'Event' => array(
                            'columns' => 'event_id',
                            'refTableClass' => 'Application_Model_DbTable_Event',
                            'refColumns' => 'id'
            )
    );
}
