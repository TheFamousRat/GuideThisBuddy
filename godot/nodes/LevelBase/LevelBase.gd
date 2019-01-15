tool

extends Node

export (Array) var availablePlaters setget availablePlaterArrayChecker

signal won
signal lost

var running : bool #Indicates whether the player has placed his layout and tests it or not

func _ready():
	set_process(get_tree().get_edited_scene_root() == null)
	running = false
	
func _process(delta):
	var bodies = $PlayerArrival.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			emit_signal("won")

func getAvailablePlaters():
	return availablePlaters

func reload():
	print("Error : Using the base function to reload the level. Won't do anything")

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

func set_running(isRunning : bool):
	running = isRunning

func isRunning():
	return running

func _input(event):
	if !running:
		$MeshInstance.set_translation(findClosestCurveShapePoint(get_viewport().get_camera().project_position(get_viewport().get_mouse_position())))

func findClosestCurvePoint(point : Vector3):#Looks in all the curves of the LevelLayout for the point on a 3d curve closest to said point
	var closestPoint : Vector3 = Vector3(INF,INF,INF)
	var currentPoint : Vector3 = Vector3(0,0,0)
	for curves in $LevelLayout.get_children():
		if curves is Path:
			currentPoint = curves.get_curve().get_closest_point(point)
			if (point - currentPoint).length() < (point - closestPoint).length():
				closestPoint = currentPoint
	
	return closestPoint
	
func findClosestCurveShapePoint(point : Vector3):
	closestCurvePoint = findClosestCurvePoint(point)

func _on_PlayerArrival_body_entered(body):
	#Called when the player reached point of arrival
	if body.is_in_group("player"):
		Engine.time_scale = 0.01
		
