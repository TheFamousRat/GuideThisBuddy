extends Area

signal rigidBodyDetected

func _ready():
	pass

func _process(delta):
	var bodies = self.get_overlapping_bodies()
	for i in bodies:
		if i is RigidBody:
			emit_signal("rigidBodyDetected")