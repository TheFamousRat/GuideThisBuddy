extends Camera

export (Vector3) var distVect
export (float) var targetDist

var target : Spatial setget setTarget

func _ready():
	pass

func _process(delta):
	if target != null:
		self.set_translation(target.get_global_transform().origin + distVect * targetDist)

func setTarget(newTarget : Spatial):
	target = newTarget
	
func centerOn(centeringTarget : Spatial, dist = targetDist, distDir = distVect):
	#This function moves the camera so that a certain Spatial is at the center of the screen (given a certain direction/distance)
	target = null
	
	if centeringTarget != null:
		self.set_translation(centeringTarget.get_global_transform().origin + distDir * dist)