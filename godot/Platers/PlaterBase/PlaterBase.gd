tool

extends Spatial

func _ready():
	set_process(get_tree().get_edited_scene_root() == null)

func is_class(type): 
	return type == "PlaterBase" or .is_type(type)
	
func get_class(): 
	return "PlaterBase"