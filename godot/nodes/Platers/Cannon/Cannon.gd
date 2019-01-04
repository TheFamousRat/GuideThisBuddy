extends "res://nodes/Platers/PlaterBase/PlaterBase.gd"

export (float) var cannonForce = 2000.0

func _on_BodyDetector_body_entered(body):
	if body.is_in_group("player"):
		body.add_central_force(cannonForce*(($Position3D.get_global_transform().origin - self.get_global_transform().origin).normalized()))
		$AnimationPlayer.play("explosion")
