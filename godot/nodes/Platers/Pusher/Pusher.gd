extends "res://nodes/Platers/PlaterBase/PlaterBase.gd"

export (float) var extensionSpeed = 100.0 #Time it takes the bumper to fully extend
export (float) var extendedStateDuration  = 0.5 #Time the bumper spends extended
export (float) var pushForce = 30.0

func _ready():
	$ExtendedTimer.wait_time = extendedStateDuration

func _on_ExtendedTimer_timeout():
	$Model/AnimationPlayer.play_backwards("default")

func _on_BodyDetector_body_entered(body):
	if body is RigidBody:
		body.apply_central_impulse(pushForce*(($Position3D.get_global_transform().origin - self.get_global_transform().origin).normalized()))
		$Model/AnimationPlayer.play("default", -1, extensionSpeed)
		$ExtendedTimer.start()
