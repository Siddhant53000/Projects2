<?php

class LearninglanguagesController extends Custom_Controller_BaseController {
    protected $_title = "Learning languages";
    protected $_tableClass = "Application_Model_DbTable_LearningLanguages";
    protected $_modelClass = "Application_Model_LearningLanguage";

    function preDispatch() {
        //parent::preDispatch();
        //$this->requireAccessLevel(3);
    }
}