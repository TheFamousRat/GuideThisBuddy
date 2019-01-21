extends Control

#Node that follows its parent on screen, if it is a Spatial node. Otherwise it wont move and act like a regular node

export (bool) var centered#If yes, SpatialStalker with be offseted by half his size

var parentInheritsSpatial : bool
var constantOffset : Vector2
var spatialParent

func _ready():
	if centered:
		constantOffset = self.get_size() * -0.5
	else:
		constantOffset = self.get_position()

	parentInheritsSpatial = false
	
	spatialParent = get_parent()
	
	while spatialParent != null:
		if spatialParent.has_method("get_translation"):
			parentInheritsSpatial = true
			break
		else:
			if spatialParent.get_parent() != null:
				spatialParent = spatialParent.get_parent()
			else:
				parentInheritsSpatial = false
				break
		
	set_process(parentInheritsSpatial)
	
func _process(delta):
	self.set_position(constantOffset + get_viewport().get_camera().unproject_position(spatialParent.get_global_transform().origin))

