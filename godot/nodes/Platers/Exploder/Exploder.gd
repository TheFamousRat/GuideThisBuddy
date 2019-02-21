extends "res://nodes/Platers/PlaterBase/PlaterBase.gd"

const EXPLOSION_STRENGTH : float = 40.0

func clone():
	var copy = self.duplicate()
	return copy

func _on_BodyDectector_body_entered(body):
	print("yeah")
	if body is RigidBody:
		var explosionDirection : Vector3 = (body.get_global_transform().origin - self.get_global_transform().origin).normalized()
		body.set_linear_velocity(explosionDirection * EXPLOSION_STRENGTH)
		self.queue_free()