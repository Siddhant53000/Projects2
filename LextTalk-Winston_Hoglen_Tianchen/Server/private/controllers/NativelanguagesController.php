<?php

class NativelanguagesController extends Custom_Controller_BaseController {
    protected $_title = "Native languages";
    protected $_tableClass = "Application_Model_DbTable_NativeLanguages";
    protected $_modelClass = "Application_Model_NativeLanguage";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}
