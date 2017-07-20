<?php
require_once 'Zend/Controller/Action.php';

class IndexController extends Zend_Controller_Action {

    function preDispatch() {
//        $user = $this->_getParam('user', "0");
//        $password = $this->_getParam('pass', "0");
//
//        if (!Custom_Auth::authControl($user, $password)) {
//            $this->_redirect('auth/login');
//        }
    }

    public function init() {
    }

    public function indexAction() {
        $this->view->title = "Welcome";
        $this->view->headTitle($this->view->title);
    }
}
