extends Control

var availablePlaters : Array

signal selectedPlater

func _ready():
	availablePlaters = Array()
	availablePlaters = get_node(Global.mainPath).getLevelAvailablePlaters()
	
	#We remove any node that doesn't inherit from PlaterBase
	for i in range(availablePlaters.size() - 2, -2, -2):
		if availablePlaters[i].can_instance():
			if availablePlaters[i].instance().get_class() != "PlaterBase":
				availablePlaters.remove(i+1)
				availablePlaters.remove(i)
				print("Warning : Some non-PlaterBase child class were seen in this level's availablePlaters array")
		else:
			availablePlaters.remove(i+1)
			availablePlaters.remove(i)

func _on_LaunchLevel_pressed():
	get_node(Global.mainPath).launchLevel()
	self.queue_free()
