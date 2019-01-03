extends "res://Platers/PlaterBase/PlaterBase.gd"

var suckForce : Vector3 = Vector3(0,0,0)
var suckStrength : float = 1000.0

func _ready():
	suckForce = (self.get_global_transform().origin - $Position3D.get_global_transform().origin).normalized()

func _process(delta):
	var bodies = $BodyDetector.get_overlapping_bodies()
	for i in bodies:
		if i.is_in_group("player"):
			i.add_force(suckForce * delta * suckStrength, Vector3(0,0,0))
