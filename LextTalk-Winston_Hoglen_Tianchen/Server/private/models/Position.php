<?php
/**
 * RelRoles
 *
 * @author
 * @version
 */

class Application_Model_Position extends Custom_Model_BaseModel {
    protected $_id;
    protected $_longitude;
    protected $_latitude;
    protected $_last_update;

    protected $_user_id;
    
    static protected $_users = null;

    protected $_id_field = '_id';

    public function getid() {
        return $this->_id;
    }

    public function setid($value) {
        $this->_id = ( integer ) $value;
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
            $news[$row->id] = $row->login_name;
        }
        self::$_users = $news;
        return self::$_users;
    }
}
