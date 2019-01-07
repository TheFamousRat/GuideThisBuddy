extends RigidBody

var savedMass : float

func _process(delta):
	pass
	
func _ready():
	savedMass = self.mass

func set_sleeping(sleeping : bool):
	self.axis_lock_linear_x = sleeping
	self.axis_lock_linear_y = sleeping
	self.axis_lock_linear_z = sleeping