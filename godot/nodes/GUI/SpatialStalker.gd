extends Control

#Node that follows its parent on screen, if it is a Spatial node. Otherwise it wont move and act like a regular node

export (bool) var centered#If yes, SpatialStalker with be offseted by half his size

var parentInheritsSpatial : bool
var constantOffset : Vector2

func _ready():
	if centered:
		constantOffset = self.get_size() * -0.5
	else:
		constantOffset = self.get_position()

	parentInheritsSpatial = false
	
	if get_parent() != null:
		if get_parent().has_method("get_translation"):
			parentInheritsSpatial = true
		else:
			parentInheritsSpatial = false
	else:
		parentInheritsSpatial = false
		
	set_process(parentInheritsSpatial)
	
func _process(delta):
	self.set_position(constantOffset + get_viewport().get_camera().unproject_position(get_parent().get_global_transform().origin))

