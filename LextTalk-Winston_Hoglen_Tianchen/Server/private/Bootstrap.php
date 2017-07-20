<?php

class Bootstrap extends Zend_Application_Bootstrap_Bootstrap
{
	public function run(){
		$config = new Zend_Config_Ini(CONFIG_FILE, 'production');
		
        $pdoParams = array(
		    PDO::MYSQL_ATTR_USE_BUFFERED_QUERY => true
		);
		$params = array(
		    'host'           => $config->resources->db->params->host,
		    'username'       => $config->resources->db->params->username,
		    'password'       => $config->resources->db->params->password,
		    'dbname'         => $config->resources->db->params->dbname,
		    'driver_options' => $pdoParams
		);
		$dbAdapter = Zend_Db::factory('PDO_MYSQL', $params);
		
	//	$registry = new Zend_Registry(array(), ArrayObject::ARRAY_AS_PROPS);
	//	Zend_Registry::setInstance($registry);
		
		Zend_Registry::set('dbAdpter', $dbAdapter);
		
	// Add jQuery
        $view = new Zend_View();
        $view->addHelperPath('ZendX/JQuery/View/Helper/', 'ZendX_JQuery_View_Helper');
        $viewRenderer = new Zend_Controller_Action_Helper_ViewRenderer();
   		// by default we disable jQuery, if you want call JQuery() from init() in your controller like this $this->view->jQuery()->active();
        $view->jQuery()->setVersion('1.4.2')
        			->setUiVersion('1.8.2');
        
        $viewRenderer->setView($view);
        Zend_Controller_Action_HelperBroker::addHelper($viewRenderer);
	// end of jQuery
	
        $view->addHelperPath('Custom/GMaps/View/Helper/', 'Custom_GMaps_View_Helper');
        $view->GMaps();
	
		parent::run();
	}
}

