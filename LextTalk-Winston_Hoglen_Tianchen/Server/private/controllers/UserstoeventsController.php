<?php

class UserstoeventsController extends Custom_Controller_BaseController {
    protected $_title = "Users to events";
    protected $_tableClass = "Application_Model_DbTable_UsersToEvents";
    protected $_modelClass = "Application_Model_UserToEvent";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}
