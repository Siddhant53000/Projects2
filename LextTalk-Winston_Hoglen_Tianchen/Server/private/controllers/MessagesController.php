<?php

class MessagesController extends Custom_Controller_BaseController {
    protected $_title = "Messages";
    protected $_tableClass = "Application_Model_DbTable_Messages";
    protected $_modelClass = "Application_Model_Message";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}
