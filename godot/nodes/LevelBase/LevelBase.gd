tool

extends Node

export (Array) var availablePlaters setget availablePlaterArrayChecker

signal won
signal lost

func _ready():
	set_process(get_tree().get_edited_scene_root() == null)
	
func _process(delta):
	var bodies = $PlayerArrival.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			emit_signal("won")

func getAvailablePlaters():
	return availablePlaters

func availablePlaterArrayChecker(newArray : Array):
	var platersArray : Array

	if newArray != null:
		if newArray.size() % 2 == 1 && newArray.size() > availablePlaters.size():
			availablePlaters = newArray.duplicate()
			availablePlaters.append(int(0))
		elif newArray.size() % 2 == 1 && newArray.size() < availablePlaters.size():
			availablePlaters = newArray.duplicate()
			availablePlaters.remove(availablePlaters.size() - 1)
		else:
			availablePlaters = newArray.duplicate()
		
		for i in availablePlaters.size():
			if i%2 == 0:
				if availablePlaters[i] != null:
					if !(availablePlaters[i] is PackedScene):
						availablePlaters[i] = PackedScene.new()
				else:
					availablePlaters[i] = PackedScene.new()
			elif i%2 == 1 and !(availablePlaters[i] is int):
				availablePlaters[i] = int(0)
				
		platersArray.clear()
		for i in range(availablePlaters.size() - 2, -2, -2):
			if platersArray.has(availablePlaters[i]):
				availablePlaters.remove(i+1)
				availablePlaters.remove(i)
			else:
				platersArray.append(availablePlaters[i])
