extends Spatial

export (float) var cannonForce = 300.0

func _process(delta):
	var bodies = $BodyDetector.get_overlapping_bodies()
	for i in bodies:
		if i is RigidBody:
			i.add_central_force(cannonForce*(($Position3D.get_global_transform().origin - self.get_global_transform().origin).normalized()))
			print("Boom")