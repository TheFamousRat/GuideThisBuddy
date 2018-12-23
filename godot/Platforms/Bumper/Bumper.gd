extends Spatial

export (float) var extensionTime = 0.01 #Time it takes the bumper to fully extend
export (float) var extendedStateDuration  = 2.0 #Time the bumper spends extended
export (float) var pushForce = 20.0

var open : bool = false

func _ready():
	$Tween.interpolate_property($Pusher, "translation", $Pusher.translation, $Pusher.translation + Vector3(0,1,0), extensionTime, Tween.TRANS_LINEAR,Tween.EASE_OUT)

	$ExtendedTimer.wait_time = extendedStateDuration

func _process(delta):
	var bodies = $Area.get_overlapping_bodies()
	for i in bodies:
			i.add_force(pushForce*(($Position3D.get_global_transform().origin - self.get_global_transform().origin).normalized()),Vector3(0,0,0))
			$Tween.set_active(true)
