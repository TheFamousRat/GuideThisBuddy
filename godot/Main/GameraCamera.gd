extends Camera

export (Vector3) var distVect
export (float) var targetDist

var target : Spatial setget setTarget

func _process(delta):
	self.set_translation(target.get_global_transform().origin + distVect * targetDist)

func setTarget(newTarget : Spatial):
	target = newTarget