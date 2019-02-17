extends Spatial

export (Texture) var GUI_Illustration
export (Material) var wrongPlacementMaterial
export (Material) var goodPlacementMaterial

signal clickedPlater

var initialRotation : Vector3
var disabled : bool
	
func _ready() -> void:
	setDisabledPlater(false)
	set_process(get_tree().get_edited_scene_root() == null)
	initialRotation = Vector3(0,0,0)
	Global.registerPlater(self)
	Global.restorePlaterMaterials(self)
	
func on_translationRequested() ->  void:
	self.setGoodPlacementShaders()
	self.setDisabledPlater(true)
	
func on_deletionRequested() -> void:
	self.setDisabledPlater(true)

func is_class(type) -> bool: 
	return type == "PlaterBase" or .is_type(type)
	
func get_class() -> String: 
	return "PlaterBase"
	
func getBaseOffset() -> Vector3:
	return $Base.get_translation()
	
func getUpVectorDirection() -> Vector3:
	return (self.get_transform() * Vector3(0,1,0)).normalized()
	
func getRotatedUpVectorDirection() -> Vector3:
	return (to_global(Vector3(0,1,0)) - to_global(Vector3(0,0,0))).normalized()

func resetRotation() -> void:
	#Resets the rotation to what the plater had in the editor
	self.set_rotation(initialRotation)
	
func getGUI_Illustration() -> Texture:
	return GUI_Illustration
	
func getPlaterPlacementDetectionArea() -> Node:
	return $PlaterPlacementDetection
	
func setWrongPlacementShaders() -> void:
	Global.setPlaterMaterial(self, wrongPlacementMaterial)

func setGoodPlacementShaders() -> void:
	Global.setPlaterMaterial(self, goodPlacementMaterial)
	
func restorePlacementShaders() -> void:
	Global.restorePlaterMaterials(self)

func setDisabledPlater(disabled_ : bool) -> void:
	disabled = disabled_
	
func _on_PlaterPlacementDetection_input_event(camera, event, click_position, click_normal, shape_idx) -> void:
	if Input.is_action_just_pressed("leftClick"):
		emit_signal("clickedPlater", self)

