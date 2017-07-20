<?php
/**
 * Application_Model_RelRoles
 *
 * @author
 * @version
 */

class Application_Model_RelRoles extends Custom_Model_BaseModel {
    protected $_user_id;
    protected $_role_id;

    static protected $_roles = null;
    static protected $_users = null;

    protected $_id_field = array("user_id" => "_user_id", "role_id" => "_role_id");

    public function getrole_id() {
        return $this->_role_id;
    }

    public function setrole_id($value) {
        $this->_role_id = ( integer ) $value;
    }

    public function getuser_id() {
        return $this->_user_id;
    }

    public function setuser_id($value) {
        $this->_user_id = ( integer ) $value;
    }

    public function role_idoptions() {
        if ( self::$_roles != null ) {
            return self::$_roles;
        }
        $table = new Application_Model_DbTable_Roles();
        $result = $table->fetchAll();

        $news = array();
        foreach ($result as $row) {
            $news[$row->role_id] = $row->description;
        }
        self::$_roles = $news;
        return self::$_roles;
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
