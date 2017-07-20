<?php

include_once 'Custom/Form/Register.php';

class Application_Form_Register extends Custom_Form_Register
{
	protected $_tableEmailField = null;
	protected $_tableNameField = 'login';
	
    public function init()
    {
        $element = new Zend_Form_Element_Text('city', array('class' => 'formFieldShort'));
        $element->setLabel('City')
        		->setRequired(true);
        $this->_customelements []= $element;

        $element = new Zend_Form_Element_Text('url', array('class' => 'formFieldLong'));
        $element->setLabel('Personal website link')
        		->addValidator(new Custom_Validate_Uri())
        		->setRequired(true);
        $this->_customelements []= $element;
        
        /*
        $element = new Zend_Form_Element_Text('url2', array('class' => 'formFieldLong'));
        $element->setLabel('Behance link')
        		->addValidator(new Custom_Validate_Uri());
        $this->_customelements []= $element;
        
        $element = new Zend_Form_Element_Checkbox('license_agreement', array('class' =>'license'));
        $element->setLabel("I agree that any information provided and images of my works (wallpapers) are used exclusively for the \"Wall for Japan\" application 
	        for iPhone and iPad Japan. I agree that images can be used to communicate the implementation Wall for 
	        Japan in the website and banners inform the application. \"Wall for Japan\" is not responsible for the wallpapers uploaded 
	        by artists, designers and illustrators.agreement")
        	->addValidator(new Custom_Validate_Termsandconditions());
        $this->_customelements []= $element;
        */
        
		parent::init();
    }
}