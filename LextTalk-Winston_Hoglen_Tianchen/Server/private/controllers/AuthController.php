<?php
/**
 * AuthController
 *
 * @author
 * @version
 */

class AuthController extends Custom_Controller_BaseAuthController {
    protected $_tableClass='Application_Model_DbTable_Users';
    protected $_modelClass='Application_Model_User';
    protected $_relRolesTable = 'Application_Model_DbTable_RelRoles';

    protected $_redirectAfterLogin = '/index';
    protected $_redirectAfterRegister = '/index';
}
