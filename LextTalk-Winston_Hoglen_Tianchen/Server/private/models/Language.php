<?php
/**
 * Application_Model_Language
 *
 * @author
 * @version
 */

class Application_Model_Language extends Custom_Model_BaseModel {
    protected $_language;

    protected $_learningLanguages;
    protected $_nativeLanguages;

    protected $_id_field = '_language';

    public function getlanguage() {
        return $this->_language;
    }

    public function setlanguage($value) {
        $this->_language = ( string ) $value;
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
}
