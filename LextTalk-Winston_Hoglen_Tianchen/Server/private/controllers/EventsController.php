<?php

class EventsController extends Custom_Controller_BaseController {
    protected $_title = "Events";
    protected $_tableClass = "Application_Model_DbTable_Events";
    protected $_modelClass = "Application_Model_Event";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}
