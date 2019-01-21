extends Control

#Node that follows its parent on screen, if it is a Spatial node. Otherwise it wont move and act like a regular node

var stalkedSpatial : Spatial

func _ready():
	pass
	
func setStalkedSpatial(newSpatial : Spatial):
	stalkedSpatial = newSpatial
	set_process(stalkedSpatial != null)
	
func _process(delta):
	self.set_position(-0.5 * self.get_scale() * self.get_size() + get_viewport().get_camera().unproject_position(stalkedSpatial.get_global_transform().origin))

