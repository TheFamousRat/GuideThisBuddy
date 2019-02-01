extends "res://nodes/Platers/PlaterBase/PlaterBase.gd"

export (float) var cannonForce = 100.0

func _on_BodyDetector_body_entered(body):
	if body is RigidBody and !disabled:
		body.set_global_transform($Position3D.get_global_transform())
		body.set_linear_velocity(cannonForce*(($Position3D.get_global_transform().origin - self.get_global_transform().origin).normalized()))
		$AnimationPlayer.play("explosion")
