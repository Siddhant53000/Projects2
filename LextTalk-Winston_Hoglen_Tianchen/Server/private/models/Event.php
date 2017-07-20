<?php
/**
 * Application_Model_Event
 *
 * @author
 * @version
 */

class Application_Model_Event extends Custom_Model_BaseModel {
    protected $_id;
    protected $_name;
    protected $_description;
    protected $_date_start;
    protected $_date_end;
    protected $_creation_date;
    protected $_private;
    protected $_active;
    protected $_url;
    protected $_max_people;
    protected $_att_people;
    protected $_longitude;
    protected $_latitude;
    protected $_last_update;
    protected $_address;
    protected $_event_type;
    protected $_paid_event;

    protected $_messages;
    protected $_usersToEvents;

    protected $_owner_id;

    static protected $_users = null;

    protected $_id_field = '_id';

    public function getid() {
        return $this->_id;
    }

    public function setid($value) {
        $this->_id = ( integer ) $value;
    }

    public function getname() {
        return $this->_name;
    }

    public function setname($value) {
        $this->_name = ( string ) $value;
    }

    public function getdescription() {
        return $this->_description;
    }

    public function setdescription($value) {
        $this->_description = ( string ) $value;
    }

    public function getdate_start() {
        return $this->_date_start;
    }

    public function setdate_start($value) {
        $this->_date_start = ( string ) $value;
    }

    public function getdate_end() {
        return $this->_date_end;
    }

    public function setdate_end($value) {
        $this->_date_end = ( string ) $value;
    }

    public function getcreation_date() {
        return $this->_creation_date;
    }

    public function setcreation_date($value) {
        $this->_creation_date = ( string ) $value;
    }

    public function getprivate() {
        return $this->_private;
    }

    public function setprivate($value) {
        $this->_private = ( bool ) $value;
    }

    public function getactive() {
        return $this->_active;
    }

    public function setactive($value) {
        $this->_active = ( bool ) $value;
    }

    public function geturl() {
        return $this->_url;
    }

    public function seturl($value) {
        $this->_url = ( string ) $value;
    }

    public function getmax_people() {
        return $this->_max_people;
    }

    public function setmax_people($value) {
        $this->_max_people = ( integer ) $value;
    }

    public function getatt_people() {
        return $this->_att_people;
    }

    public function setatt_people($value) {
        $this->_att_people = ( integer ) $value;
    }

    public function getlongitude() {
        return $this->_longitude;
    }

    public function setlongitude($value) {
        $this->_longitude = ( double ) $value;
    }

    public function getlatitude() {
        return $this->_latitude;
    }

    public function setlatitude($value) {
        $this->_latitude = ( double ) $value;
    }

    public function getlast_update() {
        return $this->_last_update;
    }

    public function setlast_update($value) {
        $this->_last_update = ( string ) $value;
    }

    public function getaddress() {
        return $this->_address;
    }

    public function setaddress($value) {
        $this->_address = ( string ) $value;
    }

    public function getevent_type() {
        return $this->_event_type;
    }

    public function setevent_type($value) {
        $this->_event_type = ( integer ) $value;
    }

    public function getpaid_event() {
        return $this->_paid_event;
    }

    public function setpaid_event($value) {
        $this->_paid_event = ( bool ) $value;
    }

    public function getowner_id() {
        return $this->_owner_id;
    }

    public function setowner_id($value) {
        $this->_owner_id = ( integer ) $value;
    }

    public function owner_idoptions() {
        if ( self::$_users != null ) {
            return self::$_users;
        }
        $table = new Application_Model_DbTable_Users();
        $result = $table->fetchAll();

        $news = array();
        foreach ($result as $row) {
            $news[$row->id] = $row->login_name;
        }
        self::$_users = $news;
        return self::$_users;
    }

    public function getmessages() {
        return $this->_messages;
    }

    public function setmessages($value) {
        $this->_messages = $this->transformVectorToModel($value, 'Application_Model_Messages');
        return $this;
    }

    public function getusersToEvents() {
        return $this->_usersToEvents;
    }

    public function setusersToEvents($value) {
        $this->_usersToEvents = $this->transformVectorToModel($value, 'Application_Model_UsersToEvents');
        return $this;
    }
}
