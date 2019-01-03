extends "res://Platers/PlaterBase/PlaterBase.gd"

func _process(delta):
	var bodies = $BodyDetector.get_overlapping_bodies()
	for i in bodies:
		if i.is_in_group("player"):
			pass
