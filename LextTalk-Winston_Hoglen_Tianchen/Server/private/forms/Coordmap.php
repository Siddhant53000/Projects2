<?php

class Application_Form_Coordmap extends Custom_Forms_BaseEditForm
{
	protected $_hiddenFields = array('lat', 'lon');

	public function init() {
		$coords = new Custom_GMaps_Form_Element_CoordinatePicker('coords');
		$coords->setLabel('Coordinates');
		if($this->_modelInstance != null) {
			$coords->setValue(array('lat' => $this->_modelInstance->lat, 'lon' => $this->_modelInstance->lon));
		}
		$this->_elements [] = $coords;
		
		parent::init();
	}
	
	public function getModelInstance() {
		$inst = parent::getModelInstance();
		$coords = $this->coords->getValue();
		$inst->setLat($coords['lat']);
		$inst->setLon($coords['lon']);
		return $inst;
	}
}