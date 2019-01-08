extends Camera

export (Vector3) var distVect = Vector3(-1,0,0)
export (float) var targetDist = 3.0
export (float) var cameraSpeed = 10.0

var target : Spatial setget setTarget

var zoom 

func _ready():
	pass

func _process(delta):
	if target != null:
		self.set_translation(target.get_global_transform().origin + distVect * targetDist)
	else:#Camera is free to move on a plane when not targeting a Spatial
		if Input.is_action_pressed("ui_left"):
			self.h_offset -= cameraSpeed * delta
		if Input.is_action_pressed("ui_right"):
			self.h_offset += cameraSpeed * delta
		if Input.is_action_pressed("ui_up"):
			self.v_offset += cameraSpeed * delta
		if Input.is_action_pressed("ui_down"):
			self.v_offset -= cameraSpeed * delta
		
func setTarget(newTarget : Spatial):
	target = newTarget
	
func centerOn(centeringTarget : Spatial, dist = targetDist, distDir = distVect):
	#This function moves the camera so that a certain Spatial is at the center of the screen (given a certain direction/distance)
	target = null
	
	if centeringTarget != null:
		self.set_translation(centeringTarget.get_global_transform().origin + distDir * dist)
		
func resetFreeCamMov():
	self.set_h_offset(0)
	self.set_v_offset(0)