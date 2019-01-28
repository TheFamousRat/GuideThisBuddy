extends Node

export (Array) var availablePlaters setget availablePlaterArrayChecker

var running : bool #Indicates whether the player has placed his layout and tests it or not
var lastClosestPoint : Vector3
var lastClosestNormal : Vector3
var upNormal : bool
var currentPlater
var maxCurveDistance : float = 2.0#Maximum distance at which the Plater is close enough to the curve to be placed on it
var lastSafePlaterTransform : Transform#Transform where the currentPlater wasn't colliding with any other plater

var positionEvaluated : bool = false
var positionSafe : bool = false#Means that a Plater is being placed 1/On something on which it can be placed 2/Where it doesn't intersects with the other platers

signal removedPlater

func _ready():
	set_process(get_tree().get_edited_scene_root() == null)
	running = false
	lastClosestNormal = Vector3()
	lastClosestPoint = Vector3()
	$PlaterPlacementPopup.set_visible(false)
	
func _process(delta):
	if currentPlater != null:
		if positionEvaluated:
			if positionSafe:
				currentPlater.setGoodPlacementShaders()
			else:
				currentPlater.setWrongPlacementShaders()
		else:
			positionEvaluated = true
			for i in currentPlater.getPlaterPlacementDetectionArea().get_overlapping_areas():
				if i.get_name() == "PlaterPlacementDetection":
					positionSafe = false

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
			elif i%2 == 1:
				if !(availablePlaters[i] is int):
					availablePlaters[i] = int(1)
				elif availablePlaters[i] <= 0:
					availablePlaters[i] = 1
				
		platersArray.clear()
		for i in range(availablePlaters.size() - 2, -2, -2):
			if platersArray.has(availablePlaters[i]):
				availablePlaters.remove(i+1)
				availablePlaters.remove(i)
			else:
				platersArray.append(availablePlaters[i])

func set_running(isRunning : bool):
	running = isRunning
	if running:
		clearCurrentPlater()

func isRunning():
	return running
	
func clearCurrentPlater():
	if currentPlater != null:
		emit_signal("removedPlater", currentPlater.get_filename())
		self.remove_child(currentPlater)
		currentPlater = null
	
func _input(event):
	if !running:
		if currentPlater != null:
			if event.is_action_pressed("rightClick"):
				
				clearCurrentPlater()
				
			elif event is InputEventMouseMotion:
				var projectedMousePoint : Vector3
				var curveShapePoint : Vector3
				
				if get_viewport().get_camera().get_projection() == Camera.PROJECTION_ORTHOGONAL:
					projectedMousePoint = get_viewport().get_camera().project_position(get_viewport().get_mouse_position())
					curveShapePoint = findClosestCurveShapePoint(projectedMousePoint)
				else:
					var mousePos = get_viewport().get_mouse_position()
					$CurveShapeDetector.set_translation(get_viewport().get_camera().project_ray_origin(mousePos))
					$CurveShapeDetector.cast_to = 10.0 * get_viewport().get_camera().project_ray_normal(mousePos)
					$CurveShapeDetector.set_collision_mask_bit(0, true)
					$CurveShapeDetector.force_raycast_update()
					$CurveShapeDetector.set_collision_mask_bit(0, false)
					
					if $CurveShapeDetector.get_collider() != null:
						print($CurveShapeDetector.get_collider().name)
						projectedMousePoint = $CurveShapeDetector.get_collision_point()
						curveShapePoint = findClosestCurveShapePoint(projectedMousePoint)
					else:
						projectedMousePoint = $CurveShapeDetector.get_translation() + $CurveShapeDetector.cast_to
						curveShapePoint = findClosestCurveShapePoint(projectedMousePoint)
					
				projectedMousePoint.z = curveShapePoint.z
				
				currentPlater.resetRotation()
	
				if ((projectedMousePoint - curveShapePoint).length() <= 1.0):
			
					currentPlater.rotate_z(-acos(-currentPlater.getRotatedUpVectorDirection().dot(lastClosestNormal)))
					
					if abs(currentPlater.getRotatedUpVectorDirection().dot(lastClosestNormal)) < 0.9999999:
						currentPlater.resetRotation()
						currentPlater.rotate_z(acos(-currentPlater.getRotatedUpVectorDirection().dot(lastClosestNormal)))
					
					currentPlater.set_translation(curveShapePoint + currentPlater.getRotatedUpVectorDirection() * 0.5 * currentPlater.getBaseOffset().length())
					
					#This follows the reasonning of "the plater is placed in a safe spot, until something else proves otherwise"
					positionEvaluated = false
					positionSafe = true
				else:
					currentPlater.set_translation(projectedMousePoint)
					positionEvaluated = true
					positionSafe = false
					
			if event.is_action_pressed("leftClick") and positionEvaluated and positionSafe:
				
				Input.action_release("leftClick")
				var nextPlater = currentPlater.duplicate()
				self.add_child(nextPlater)
				nextPlater.connect("clickedPlater", self, "onClickedPlater")
				self.remove_child(currentPlater)
				currentPlater = null

func findClosestCurveShapePoint(point : Vector3):#Looks in all the curves of the LevelLayout for the point on a 3d curve closest to said point
	var closestPoint : Vector3 = Vector3(INF,INF,INF)
	var currentPoint : Vector3 = Vector3(0,0,0)
	var closestCurve : Curve3D
	var closestPath : Path
	var closestOffset : float
	
	for curves in $LevelLayout.get_children():
		if curves.has_method("getCollisionBody"):
			curves.getCurvedMesh()
			currentPoint = curves.get_curve().get_closest_point(point)
			if (point - currentPoint).length() < (point - closestPoint).length():
				closestPoint = currentPoint
				closestOffset = curves.get_curve().get_closest_offset(point)
				closestCurve = curves.get_curve()
				closestPath = curves

	var pointVector : Vector3 = point - closestPoint
	var usedUpVector : Vector3
	if pointVector.normalized().dot(-closestCurve.interpolate_baked_up_vector(closestOffset)) > pointVector.normalized().dot(closestCurve.interpolate_baked_up_vector(closestOffset)):
		upNormal = false
		usedUpVector = -closestCurve.interpolate_baked_up_vector(closestOffset)
	else:
		upNormal = true
		usedUpVector = closestCurve.interpolate_baked_up_vector(closestOffset)
	
	$CurveShapeDetector.set_translation(closestPoint)
	$CurveShapeDetector.set_cast_to(usedUpVector * 10.0)
	$CurveShapeDetector.set_enabled(true)
	$CurveShapeDetector.set_exclude_parent_body(false)
	$CurveShapeDetector.clear_exceptions()
	
	#This is made so that the raycast only intersects with the given body
	closestPath.getCollisionBody().set_collision_layer_bit(19, true)
	
	$CurveShapeDetector.force_raycast_update()
	lastClosestNormal = $CurveShapeDetector.get_collision_normal()
	lastClosestPoint = $CurveShapeDetector.get_collision_point()
	
	closestPath.getCollisionBody().set_collision_layer_bit(19, false)
	
	return lastClosestPoint

func _on_PlayerArrival_body_entered(body):
	#Called when the player reached point of arrival
	if body.is_in_group("player"):
		Engine.time_scale = 0.01
		get_node(Global.mainPath).levelComplete()

func placeNewPlater(newPlater : PackedScene):
	if currentPlater != null:
		self.add_child(currentPlater.duplicate())
		self.remove_child(currentPlater)
		
	currentPlater = newPlater.instance()
	self.add_child(currentPlater)
	currentPlater.on_translationRequested()
	lastSafePlaterTransform = currentPlater.get_global_transform()
		
	for i in range(0, availablePlaters.size(), 2):
		if availablePlaters[i] == newPlater:
			availablePlaters[i+1] -= 1
			
func onClickedPlater(clickedPlater):
	if clickedPlater != currentPlater:
		$PlaterPlacementPopup.setStalkedSpatial(clickedPlater)
		$PlaterPlacementPopup.show()

func _on_PlaterPlacementPopup_rotationRequested():
	$PlaterPlacementPopup.getStalkedSpatial().on_rotationRequested()

func _on_PlaterPlacementPopup_translationRequested():
	$PlaterPlacementPopup.getStalkedSpatial().on_translationRequested()
	currentPlater = $PlaterPlacementPopup.getStalkedSpatial()
	currentPlater.resetRotation()
	$fixed3DPoint.set_transform(currentPlater.get_global_transform())
	$PlaterPlacementPopup.setStalkedSpatial($fixed3DPoint)
	$PlaterPlacementPopup.hide()

func _on_PlaterPlacementPopup_deletionRequested():
	$PlaterPlacementPopup.getStalkedSpatial().on_deletionRequested()
	currentPlater = $PlaterPlacementPopup.getStalkedSpatial()
	$fixed3DPoint.set_transform(currentPlater.get_global_transform())
	$PlaterPlacementPopup.setStalkedSpatial($fixed3DPoint)
	$PlaterPlacementPopup.hide()
	clearCurrentPlater()
