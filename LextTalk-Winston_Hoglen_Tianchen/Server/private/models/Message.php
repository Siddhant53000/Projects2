<?php
/**
 * Application_Model_Message
 *
 * @author
 * @version
 */

class Application_Model_Message extends Custom_Model_BaseModel {
    protected $_id;
    protected $_sent_time;
    protected $_recv_time;
    protected $_last_state_change;
    protected $_deliver_status;
    protected $_body;

    protected $_from_id;
    protected $_to_id;
    protected $_event_id;

    protected $_id_field = '_id';

    public function getid() {
        return $this->_id;
    }

    public function setid($value) {
        $this->_id = ( integer ) $value;
    }

    public function getsent_time() {
        return $this->_sent_time;
    }

    public function setsent_time($value) {
        $this->_sent_time = ( string ) $value;
    }

    public function getrecv_time() {
        return $this->_recv_time;
    }

    public function setrecv_time($value) {
        $this->_recv_time = ( string ) $value;
    }

    public function getlast_state_change() {
        return $this->_last_state_change;
    }

    public function setlast_state_change($value) {
        $this->_last_state_change = ( string ) $value;
    }

    public function getdeliver_status() {
        return $this->_deliver_status;
    }

    public function setdeliver_status($value) {
        $this->_deliver_status = ( integer ) $value;
    }

    public function getbody() {
        return $this->_body;
    }

    public function setbody($value) {
        $this->_body = ( string ) $value;
    }

    public function getfrom_id() {
        return $this->_from_id;
    }

    public function setfrom_id($value) {
        $this->_from_id = ( integer ) $value;
    }

    public function from_idoptions () {
            if ( self::$_users != null ) {
                    return self::$_users;
            }
            $table = new Application_Model_DbTable_Users();
            $result = $table->fetchAll();

            $news = array();
            foreach ($result as $row) {
                    $news[$row->id] = $row->name;
            }
            self::$_users = $news;
            return self::$_users;
    }

    public function getto_id() {
        return $this->_to_id;
    }

    public function setto_id($value) {
        $this->_to_id = ( integer ) $value;
    }

    public function to_idoptions () {
            return $this->from_idoptions();
    }

    public function getevent_id() {
        return $this->_event_id;
    }

    public function setevent_id($value) {
        $this->_event_id = ( integer ) $value;
    }

    public function event_idoptions () {
            if ( self::$_events != null ) {
                    return self::$_events;
            }
            $table = new Application_Model_DbTable_Events();
            $result = $table->fetchAll();

            $news = array();
            foreach ($result as $row) {
                    $news[$row->id] = $row->name;
            }
            self::$_events = $news;
            return self::$_eventss;
    }
}
