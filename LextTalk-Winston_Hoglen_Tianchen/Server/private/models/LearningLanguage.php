<?php
/**
 * Application_Model_LearningLanguage
 *
 * @author
 * @version
 */

class Application_Model_LearningLanguage extends Custom_Model_BaseModel {
    protected $_flag;
    protected $_active;

    protected $_user_id;
    protected $_language_id;

    static protected $_users = null;
    static protected $_languages = null;

    protected $_id_field = array('user' => '_user_id', 'language' => '_language_id');

    public function getflag() {
        return $this->_flag;
    }

    public function setflag($value) {
        $this->_flag = ( integer ) $value;
    }

    public function getactive() {
        return $this->_active;
    }

    public function setactive($value) {
        $this->_active = ( bool ) $value;
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

    public function getlanguage_id() {
        return $this->_language_id;
    }

    public function setlanguage_id($value) {
        $this->_language_id = ( string ) $value;
    }

    public function language_idoptions () {
            if ( self::$_languages != null ) {
                    return self::$_languages;
            }
            $table = new Application_Model_DbTable_Languages();
            $result = $table->fetchAll();

            $news = array();
            foreach ($result as $row) {
                    $news[$row->language] = $row->language;
            }
            self::$_languages = $news;
            return self::$_languages;
    }
}
