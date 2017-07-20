<?php
/**
 * Application_Model_User
 *
 * @author
 * @version
 */

class Application_Model_User extends Custom_Model_BaseModel {
    protected $_id;
    protected $_token;
    protected $_login_name;
    protected $_password;
    protected $_screen_name;
    protected $_last_update;
    protected $_creation_date;
    protected $_apns_token;
    protected $_twitter;
    protected $_mail;
    protected $_url;
    protected $_address;
    protected $_has_picture;
    protected $_fuzzy_location;

    protected $_relroles;
    protected $_postions;
    protected $_learningLanguages;
    protected $_nativeLanguages;
    protected $_toMessages;
    protected $_fromMessages;
    protected $_ownerEvent;
    protected $_usersToEvents;

    protected $_id_field = '_id';

    public function getid() {
        return $this->_id;
    }

    public function setid($value) {
        $this->_id = ( integer ) $value;
    }

    public function gettoken() {
        return $this->_token;
    }

    public function settoken($value) {
        $this->_token = ( string ) $value;
    }

    public function getlogin_name() {
        return $this->_login_name;
    }

    public function setlogin_name($value) {
        $this->_login_name = ( string ) $value;
    }

    public function getpassword() {
        return $this->_password;
    }

    public function setpassword($value) {
        $this->_password = ( string ) $value;
    }

    public function getscreen_name() {
        return $this->_screen_name;
    }

    public function setscreen_name($value) {
        $this->_screen_name = ( string ) $value;
    }

    public function getlast_update() {
        return $this->_last_update;
    }

    public function setlast_update($value) {
        $this->_last_update = ( string ) $value;
    }

    public function getcreation_date() {
        return $this->_creation_date;
    }

    public function setcreation_date($value) {
        $this->_creation_date = ( string ) $value;
    }

    public function gettwitter() {
        return $this->_twitter;
    }

    public function settwitter($value) {
        $this->_twitter = ( string ) $value;
    }

    public function getmail() {
        return $this->_mail;
    }

    public function setmail($value) {
        $this->_mail = ( string ) $value;
    }

    public function geturl() {
        return $this->_url;
    }

    public function seturl($value) {
        $this->_url = ( string ) $value;
    }

    public function getaddress() {
        return $this->_address;
    }

    public function setaddress($value) {
        $this->_address = ( string ) $value;
    }

    public function gethas_picture() {
        return $this->_has_picture;
    }

    public function sethas_picture($value) {
        $this->_has_picture = ( bool ) $value;
    }

    public function getfuzzy_location() {
        return $this->_fuzzy_location;
    }

    public function setfuzzy_location($value) {
        $this->_fuzzy_location = ( bool ) $value;
    }

    public function getrelroles() {
        return $this->_relroles;
    }

    public function setrelroles($value) {
        $this->_relroles = $this->transformVectorToModel($value, 'Application_Model_RelRoles');
        return $this;
    }

    public function getpostions() {
        return $this->_postions;
    }

    public function setpostions($value) {
        $this->_postions = $this->transformVectorToModel($value, 'Application_Model_Positions');
        return $this;
    }

    public function getlearningLanguages() {
        return $this->_learningLanguages;
    }

    public function setlearningLanguages($value) {
        $this->_learningLanguages = $this->transformVectorToModel($value, 'Application_Model_LearningLanguages');
        return $this;
    }

    public function getnativeLanguages() {
        return $this->_nativeLanguages;
    }

    public function setnativeLanguages($value) {
        $this->_nativeLanguages = $this->transformVectorToModel($value, 'Application_Model_NativeLanguages');
        return $this;
    }

    public function gettoMessages() {
        return $this->_toMessages;
    }

    public function settoMessages($value) {
        $this->_toMessages = $this->transformVectorToModel($value, 'Application_Model_Messages');
        return $this;
    }

    public function getfromMessages() {
        return $this->_fromMessages;
    }

    public function setfromMessages($value) {
        $this->_fromMessages = $this->transformVectorToModel($value, 'Application_Model_Messages');
        return $this;
    }

    public function getownerEvent() {
        return $this->_ownerEvent;
    }

    public function setownerEvent($value) {
        $this->_ownerEvent = $this->transformVectorToModel($value, 'Application_Model_Events');
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
