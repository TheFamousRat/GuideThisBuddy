extends Spatial

export (Texture) var GUI_Illustration
export (bool) var enabledTranslation
export (bool) var enabledRotation
export (Material) var wrongPlacementMaterial
export (Material) var goodPlacementMaterial

signal clickedPlater

var initialRotation : Vector3
var disabled : bool
	
func _ready():
	setDisabledPlater(false)
	set_process(get_tree().get_edited_scene_root() == null)
	initialRotation = Vector3(0,0,0)
	Global.registerPlater(self)
	Global.restorePlaterMaterials(self)
	
func on_translationRequested():
	self.setGoodPlacementShaders()

func on_rotationRequested():
	pass
	
func on_deletionRequested():
	pass

func is_class(type): 
	return type == "PlaterBase" or .is_type(type)
	
func get_class(): 
	return "PlaterBase"
	
func getBaseOffset():
	return $Base.get_translation() - $Origin.get_translation()
	
func getUpVectorDirection():
	return ($Up.get_translation() - $Origin.get_translation()).normalized()
	
func getRotatedUpVectorDirection():
	return ($Up.get_global_transform().origin - $Origin.get_global_transform().origin).normalized()
	
func resetRotation():
	#Resets the rotation to what the plater had in the editor
	self.set_rotation(initialRotation)
	
func getGUI_Illustration():
	return GUI_Illustration
	
func getPlaterPlacementDetectionArea():
	return $PlaterPlacementDetection
	
func setWrongPlacementShaders():
	Global.setPlaterMaterial(self, wrongPlacementMaterial)

func setGoodPlacementShaders():
	Global.setPlaterMaterial(self, goodPlacementMaterial)
	
func restorePlacementShaders():
	Global.restorePlaterMaterials(self)

func setDisabledPlater(disabled_ : bool):
	disabled = disabled_
	
func _on_PlaterPlacementDetection_input_event(camera, event, click_position, click_normal, shape_idx):
	if Input.is_action_just_pressed("leftClick"):
		emit_signal("clickedPlater", self)

