<?php

class UsersController extends Custom_Controller_BaseController {
    protected $_title = "User";
    protected $_tableClass = "Application_Model_DbTable_Users";
    protected $_modelClass = "Application_Model_User";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}
