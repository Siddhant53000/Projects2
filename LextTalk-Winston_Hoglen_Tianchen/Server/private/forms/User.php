<?php

class Application_Form_User extends Custom_Forms_BaseEditForm
{

	protected $_visibleFields = array("user_id", "login", "password");
	
    public function init()
    {
    	/*
      $picture = new Custom_Form_Element_Image('picture');
      $picture->setLabel('Upload an image:')
              ->setDestination('/tmp')
              ->addValidator('Count', false, 1) // ensure only 1 file
              ->addValidator('Size', false, 1024000) // limit to 1000K
              ->addValidator('Extension', false, array('jpeg','jpg'));//only JPEG, PNG, and GIFs
        $this->_elements []= $picture;
        
        $coords = new Custom_GMaps_Form_Element_CoordinatePicker('coords');
        $coords->setLabel('Coordinates');
        if ( $this->_modelInstance!= null ) {
        	$coords->setValue(array('lat'=>$this->_modelInstance->lat,'lon'=>$this->_modelInstance->lon));
        }
        $this->_elements []= $coords;

        parent::init();
        
        $this->url->addValidator(new Custom_Validate_Uri());
        */
    	
		$this->_elements = array();
		 
		$this->fillMemberVars();
		$this->getFormFieldNames();
		
        $user_id = new Zend_Form_Element_Text('user_id');
        $user_id->setLabel("User id");
        $user_id->setValue($this->_modelInstance->getUser_id());
        $user_id->setAttrib('readonly', true);
		$user_id->class = "idfield";
		$this->_elements []= $user_id;

		$login = new Zend_Form_Element_Text('login');
        $login->setLabel("Login name");
        $login->setValue($this->_modelInstance->getLogin());
        if ( isset($this->_modelInstance) ) {
        	// we're editing
        	$mapper = new Custom_Model_BaseMapper(array("modelClass"=>"Application_Model_User"));
        	$instance = $mapper->modelToArray($this->_modelInstance);
        	$login->addValidator(new Custom_Validate_Unique("Application_Model_DbTable_Users","login",$instance));
        } else {
        	$login->addValidator(new Custom_Validate_Unique("Application_Model_DbTable_Users","login"));
        }
		$this->_elements []= $login;
        
		$password = new Zend_Form_Element_Password('password');
        $password->setLabel("Password name");
        $password->setValue($this->_modelInstance->getPassword());
		$this->_elements []= $password;

		// Submit button
		$submit = new Zend_Form_Element_Submit('editsubmit');
		$submit->setDecorators(array('ViewHelper'));
		$submit->setLabel("Accept changes");
		$this->_elements []= $submit;

		// Build the forms adding all elements
		$this->setName('editform');
		$this->addElements($this->_elements);
    }
    
    public function getModelInstance() {
    	$inst = parent::getModelInstance();
    	/*
    	$source = $this->picture->getFileName();
    	if ( gettype($source) != 'array') {
    		$inst->setHas_picture(1);
    	}
    	$coords = $this->coords->getValue();
    	$inst->setLat($coords['lat']);
    	$inst->setLon($coords['lon']);
    	*/
    	$newpassword = $inst->getPassword();
    	if ( isset($newpassword) ) {
    		$newpassword = Custom_Auth::hashPassword($newpassword);
    		$inst->setPassword($newpassword);
    	}
    	return $inst;
    }
}
