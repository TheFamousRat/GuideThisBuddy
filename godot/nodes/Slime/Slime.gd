extends RigidBody

func _process(delta):
	pass
	
func _ready():
	pass

func set_sleeping(sleeping : bool):
	self.set_axis_lock(PhysicsServer.BODY_AXIS_LINEAR_X, sleeping)
	self.set_axis_lock(PhysicsServer.BODY_AXIS_LINEAR_Y, sleeping)
	self.set_axis_lock(PhysicsServer.BODY_AXIS_LINEAR_Z, sleeping)