extends RigidBody

func _process(delta):
	pass
	
func _ready():
	pass

func set_sleeping(sleeping : bool):
	if sleeping:
		self.set_mode(RigidBody.MODE_STATIC)
	else:
		self.set_mode(RigidBody.MODE_RIGID)