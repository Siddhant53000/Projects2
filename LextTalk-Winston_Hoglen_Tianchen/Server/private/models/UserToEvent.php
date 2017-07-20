<?php
/**
 * Application_Model_UserToEvent
 *
 * @author
 * @version
 */

class Application_Model_UserToEvent extends Custom_Model_BaseModel {
    protected $_user_id;
    protected $_event_id;
    protected $_join_date;

    static protected $_users = null;
    static protected $_events = null;

    protected $_id_field = array("user_id" => "_user_id", "event_id" => "_event_id");

    public function getjoin_date() {
        return $this->_join_date;
    }

    public function setjoin_date($value) {
        $this->_join_date = ( string ) $value;
    }

    public function getevent_id() {
        return $this->_event_id;
    }

    public function setevent_id($value) {
        $this->_event_id = ( integer ) $value;
    }

    public function event_idoptions() {
        if ( self::$_events != null ) {
            return self::$_events;
        }
        $table = new Application_Model_DbTable_Events();
        $result = $table->fetchAll();

        $news = array();
        foreach ($result as $row) {
            $news[$row->id] = $row->description;
        }
        self::$_events = $news;
        return self::$_events;
    }

    public function getuser_id() {
        return $this->_user_id;
    }

    public function setuser_id($value) {
        $this->_user_id = ( integer ) $value;
    }

    public function user_idoptions() {
        if ( self::$_users != null ) {
            return self::$_users;
        }
        $table = new Application_Model_DbTable_Users();
        $result = $table->fetchAll();

        $news = array();
        foreach ($result as $row) {
            $news[$row->id] = $row->login;
        }
        self::$_users = $news;
        return self::$_users;
    }
}
