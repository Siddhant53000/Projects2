<?php
/**
 * Application_Model_Session
 *
 * @author
 * @version
 */

class Application_Model_Session extends Custom_Model_BaseModel {
    protected $_id;
    protected $_udid;
    protected $_os_version;
    protected $_device_type;
    protected $_app_version;
    protected $_lang_code;

    protected $_user_id;

    static protected $_users = null;

    protected $_id_field = '_id';

    public function getid() {
        return $this->_id;
    }

    public function setid($value) {
        $this->_id = ( integer ) $value;
    }

    public function getudid() {
        return $this->_udid;
    }

    public function setudid($value) {
        $this->_udid = ( string ) $value;
    }

    public function getos_version() {
        return $this->_os_version;
    }

    public function setos_version($value) {
        $this->_os_version = ( string ) $value;
    }

    public function getdevice_type() {
        return $this->_device_type;
    }

    public function setdevice_type($value) {
        $this->_device_type = ( string ) $value;
    }

    public function getapp_version() {
        return $this->_app_version;
    }

    public function setapp_version($value) {
        $this->_app_version = ( string ) $value;
    }

    public function getlang_code() {
        return $this->_lang_code;
    }

    public function setlang_code($value) {
        $this->_lang_code = ( string ) $value;
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
