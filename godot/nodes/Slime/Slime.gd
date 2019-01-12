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
		
func _integrate_forces(state):
	print(state.linear_velocity)
	if state.get_linear_velocity() == Vector3(0,0,0):
		state.set_linear_velocity(Vector3(0,0.0000002,0))