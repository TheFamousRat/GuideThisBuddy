extends Spatial

export (Array) var availablePlaters setget availablePlaterArrayChecker

var running : bool #Indicates whether the player has placed his layout and tests it or not
var lastClosestPoint : Vector3
var lastClosestNormal : Vector3

var currentPlater#Current Plater being placed
var currentPotentialParent : NodePath#When a plater is placed, it is added as a child of the curve it is placed on
var maxCurvePlaterDistance : float = 1.0#Maximum distance at which the Plater is close enough to the curve to be placed on it
var allMeshCurverPath : Array = Array()#Contains the path of all MeshCurver

var positionEvaluated : bool = false
var positionSafe : bool = false#Means that a Plater is being placed 1/On something on which it can be placed 2/Where it doesn't intersects with the other platers
var curveOffsetHasMesh : bool#False if the closest point on the curve has no mesh on it

signal removedPlater

func _ready() -> void:
	set_process(get_tree().get_edited_scene_root() == null)
	running = false
	lastClosestNormal = Vector3()
	lastClosestPoint = Vector3()
	$PlaterPlacementPopup.set_visible(false)
	allMeshCurverPath = Array()
	getAllCurves(self)
	
#Recursive function that finds all the MeshCurver in the tree
func getAllCurves(node) -> void:
	if node != null:
		if node.has_method("getCollisionBody"):
			allMeshCurverPath.append(node.get_path())
		for i in node.get_children():
			getAllCurves(i)
	
func _physics_process(delta) -> void:
	if currentPlater != null:
		if positionEvaluated:
			if positionSafe:
				currentPlater.setGoodPlacementShaders()
			else:
				currentPlater.setWrongPlacementShaders()
		else:
			positionEvaluated = true
			positionSafe = true
			
			for i in currentPlater.getPlaterPlacementDetectionArea().get_overlapping_areas():
				if i.get_name() == "PlaterPlacementDetection" and i.get_owner() != currentPlater:
					positionSafe = false
					break


func getAvailablePlaters() -> Array:
	return availablePlaters

func reload() -> void:
	print("Error : Using the base function to reload the level. Won't do anything")

func availablePlaterArrayChecker(newArray : Array) -> void:
	var platersArray : Array = Array()

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

func set_running(isRunning : bool) -> void:
	running = isRunning
	if running:
		clearCurrentPlater()
		$PlaterPlacementPopup.set_visible(false)
	
	if get_viewport().get_camera().get_class() == "GameCamera":
		get_viewport().get_camera().setZoomAllowed(!isRunning)
		if running:
			get_viewport().get_camera().setTargetDist(30)
		
	setPlatersChildsDisabled(self, !isRunning)
	
func isRunning() -> bool:
	return running
	
func setPlatersChildsDisabled(parent, disabled : bool) -> void:#Disabled all the children of a certain node (including the node itself) that are platers
	if parent != null:
		if parent.get_class() == "PlaterBase":
			parent.setDisabledPlater(disabled)
		for i in parent.get_children():
			setPlatersChildsDisabled(i, disabled)
	
func clearCurrentPlater() -> void:
	if currentPlater != null:
		emit_signal("removedPlater", currentPlater.get_filename())
		currentPlater.get_parent().remove_child(currentPlater)
		currentPlater = null
	
func _input(event) -> void:
	if !running:
		if currentPlater != null:
			if event.is_action_pressed("rightClick"):
				clearCurrentPlater()
				
			elif event is InputEventMouseMotion:
				var projectedMousePoint : Vector3
				var curveShapePoint : Vector3
				var multFact : float
				
				if get_viewport().get_camera().has_method("getTargetDist"):
					multFact = get_viewport().get_camera().getTargetDist()
				else:
					multFact = 1.0
					
				var cameraRayNormal : Vector3 = get_viewport().get_camera().project_ray_normal(get_viewport().get_mouse_position())
				var cameraRayOrigin : Vector3 = get_viewport().get_camera().project_ray_origin(get_viewport().get_mouse_position())
				projectedMousePoint = multFact * cameraRayNormal + cameraRayOrigin
				curveShapePoint = findClosestCurveShapePoint(projectedMousePoint)
				
				projectedMousePoint = ((curveShapePoint.z-cameraRayOrigin.z)/cameraRayNormal.z) * cameraRayNormal + cameraRayOrigin
				currentPlater.resetRotation()
	
				if ((projectedMousePoint - curveShapePoint).length() <= maxCurvePlaterDistance) and curveOffsetHasMesh:
			
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
				#We release this action so that the Game doesn't consider the player clicked the Plater right away
				Input.action_release("leftClick")
				var nextPlater = currentPlater.clone()
				
				#We move the plater so that its parent potential Transform doesn't affect the position at which the player desired to place it
				nextPlater.set_translation(get_node(currentPotentialParent).to_local(nextPlater.get_translation()))
				nextPlater.set_rotation(nextPlater.get_rotation() - get_node(currentPotentialParent).get_global_transform().basis.get_euler())

				#We then add the Plater to its new parent
				get_node(currentPotentialParent).add_child(nextPlater)
				nextPlater.setDisabledPlater(true)
				nextPlater.connect("clickedPlater", self, "onClickedPlater")
				currentPlater.get_parent().remove_child(currentPlater)
				currentPlater = null

func findClosestCurveShapePoint(point : Vector3) -> Vector3:#Looks in all the curves of the LevelLayout for the point on a 3d curve closest to said point
	var closestPoint : Vector3 = Vector3(INF,INF,INF)
	var currentPoint : Vector3 = Vector3(0,0,0)
	var closestCurve : Curve3D
	var closestPath : Path
	var closestOffset : float
	
	for i in allMeshCurverPath:
		var curves = get_node(i)
		var tempPoint : Vector3 = curves.to_local(point)
		curves.getCurvedMesh()
		currentPoint = curves.get_curve().get_closest_point(tempPoint)
		if (tempPoint - currentPoint).length() < (tempPoint - closestPoint).length():
			closestPoint = curves.to_global(currentPoint)#currentPoint + curves.get_global_transform().origin
			closestOffset = curves.get_curve().get_closest_offset(tempPoint)
			closestCurve = curves.get_curve()
			closestPath = curves
	
	currentPotentialParent = closestPath.get_path()
	
	var pointVector : Vector3 = point - closestPoint
	var usedUpVector : Vector3
	if pointVector.normalized().dot(-closestCurve.interpolate_baked_up_vector(closestOffset)) > pointVector.normalized().dot(closestCurve.interpolate_baked_up_vector(closestOffset)):
		usedUpVector = -closestCurve.interpolate_baked_up_vector(closestOffset)
	else:
		usedUpVector = closestCurve.interpolate_baked_up_vector(closestOffset)
	
	usedUpVector = closestPath.get_global_transform().basis * usedUpVector
	
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
	
	curveOffsetHasMesh = ($CurveShapeDetector.get_collider() != null)
	
	return lastClosestPoint

func _on_PlayerArrival_body_entered(body) -> void:
	#Called when the player reached point of arrival
	if body.is_in_group("player"):
		Engine.time_scale = 0.01
		get_node(Global.mainPath).levelComplete()

func placeNewPlater(newPlater : PackedScene) -> void:
	clearCurrentPlater()
		
	currentPlater = newPlater.instance()
	self.add_child(currentPlater)
	currentPlater.on_translationRequested()
	currentPlater.setDisabledPlater(true)
		
	for i in range(0, availablePlaters.size(), 2):
		if availablePlaters[i] == newPlater:
			availablePlaters[i+1] -= 1
			
func onClickedPlater(clickedPlater) -> void:
	if clickedPlater != currentPlater:
		$PlaterPlacementPopup.setStalkedSpatial(clickedPlater)
		$PlaterPlacementPopup.show()

#The Placement GUI launches its hide animation, without moving
func hidePlacementGuiStatically() -> void:
	$fixed3DPoint.set_transform($PlaterPlacementPopup.getStalkedSpatial().get_global_transform())
	$PlaterPlacementPopup.setStalkedSpatial($fixed3DPoint)
	$PlaterPlacementPopup.hide()

#When the player clicks on the "rotate" button
func _on_PlaterPlacementPopup_rotationRequested() -> void:
	$PlaterPlacementPopup.getStalkedSpatial().on_rotationRequested()
	hidePlacementGuiStatically()

#When the player clicks on the "translate" button
func _on_PlaterPlacementPopup_translationRequested() -> void:
	$PlaterPlacementPopup.getStalkedSpatial().on_translationRequested()
	
	currentPlater = $PlaterPlacementPopup.getStalkedSpatial()
	currentPlater.resetRotation()
	currentPlater.set_as_toplevel(true)
	
	hidePlacementGuiStatically()

#When the player requests the deletion of the currentPlater
func _on_PlaterPlacementPopup_deletionRequested() -> void:
	$PlaterPlacementPopup.getStalkedSpatial().on_deletionRequested()
	currentPlater = $PlaterPlacementPopup.getStalkedSpatial()
	hidePlacementGuiStatically()
	clearCurrentPlater()

#When the player requests to change the orientation of the Sucker (exclusive to that Plater)
func _on_PlaterPlacementPopup_suckerOrientation() -> void:
	var targetedSucker = $PlaterPlacementPopup.getStalkedSpatial()
	targetedSucker.on_suckerOrientationRequested()
	hidePlacementGuiStatically()