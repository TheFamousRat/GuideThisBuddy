tool

extends Spatial

export (Texture) var GUI_Illustration
export (bool) var enabledTranslation
export (bool) var enabledRotation

signal clickedPlater

var initialRotation : Vector3

func _ready():
	set_process(get_tree().get_edited_scene_root() == null)
	initialRotation = Vector3(0,0,0)
	
func on_translationRequested():
	print("SomePlaterIdk : Oh boy, translation requested")

func on_rotationRequested():
	print("SomePlaterIdk : Oh boy, rotation requested")
	
func on_deletionRequested():
	print("SomePlaterIdk : Oh boy, deletion requested")

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

func _on_PlaterPlacementDetection_input_event(camera, event, click_position, click_normal, shape_idx):
	if Input.is_action_just_pressed("leftClick"):
		emit_signal("clickedPlater", self)
