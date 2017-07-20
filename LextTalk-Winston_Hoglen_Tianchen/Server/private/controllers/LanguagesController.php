<?php

class LanguagesController extends Custom_Controller_BaseController {
    protected $_title = "Languages";
    protected $_tableClass = "Application_Model_DbTable_Languages";
    protected $_modelClass = "Application_Model_Language";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}
