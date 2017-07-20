<?php

class SessionsController extends Custom_Controller_BaseController {
    protected $_title = "Sessions";
    protected $_tableClass = "Application_Model_DbTable_Sessions";
    protected $_modelClass = "Application_Model_Session";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}
