extends "res://nodes/Platers/PlaterBase/PlaterBase.gd"

export (float) var extensionSpeed = 100.0 #Time it takes the bumper to fully extend
export (float) var extendedStateDuration  = 0.5 #Time the bumper spends extended
export (float) var pushForce = 20.0

func _ready():
	$ExtendedTimer.wait_time = extendedStateDuration
	
func _process(delta):
	var bodies = $Area.get_overlapping_bodies()
	for i in bodies:
		if i is RigidBody:
			i.add_force(pushForce*(($Position3D.get_global_transform().origin - self.get_global_transform().origin).normalized()),Vector3(0,0,0))
			$Model/AnimationPlayer.play("default", -1, extensionSpeed)
			$ExtendedTimer.start()
			
func _on_ExtendedTimer_timeout():
	$Model/AnimationPlayer.play_backwards("default")
