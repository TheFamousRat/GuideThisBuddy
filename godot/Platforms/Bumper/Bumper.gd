extends Spatial

export (float) var extensionTime = 0.01 #Time it takes the bumper to fully extend
export (float) var extendedStateDuration  = 2.0 #Time the bumper spends extended

var open : bool = false

func _ready():
	$Tween.interpolate_property($Pusher, "translation", $Pusher.translation, $Pusher.translation + Vector3(0,1,0), extensionTime, Tween.TRANS_LINEAR,Tween.EASE_OUT)

	$ExtendedTimer.wait_time = extendedStateDuration

func _on_Area_rigidBodyDetected():
	$Tween.set_active(true)
