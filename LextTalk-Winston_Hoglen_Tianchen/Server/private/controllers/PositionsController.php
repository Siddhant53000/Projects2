<?php

class PositionsController extends Custom_Controller_BaseController {
    protected $_title = "Native languages";
    protected $_tableClass = "Application_Model_DbTable_Positions";
    protected $_modelClass = "Application_Model_Position";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}
