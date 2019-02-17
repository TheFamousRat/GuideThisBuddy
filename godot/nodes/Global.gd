extends Node

var mainPath : NodePath = "/root/Main"
var gameCameraPath : NodePath = "/root/Main/GameCamera"

class localizedMaterialInfo:
	var path : String 
	var material : Material
	var surfaceIndex : int
		
	func _init(path_ : String, material_ : Material, surfaceIndex_ : int):
		path = path_
		material = material_
		surfaceIndex = surfaceIndex_
		return self
	
	func getPath():
		return path
		
	func getMaterial():
		return material
	
	func getSurfaceIndex():
		return surfaceIndex
		
	func setPath(path_ : String):
		path = path_
		
	func setMaterial(material_ : Material):
		material = material_
		
	func setSurfaceIndex(surfaceIndex_ : int):
		surfaceIndex = surfaceIndex_
		
var storedPlaterFilename : Array = Array()
var storedPlaterLocalizedMeshMaterials : Array = Array()
	
func registerPlater(plater):
	if plater.get_class() != "PlaterBase":
		print("Error : can only register Platers")
	else:
		if !storedPlaterFilename.has(plater.get_filename()):
			storedPlaterFilename.append(plater.get_filename())
			storedPlaterLocalizedMeshMaterials.append(Array())
			registerPlaterMaterials(plater, plater)
			
func registerPlaterMaterials(node : Node, nodeOwner : Node):
	if node != null:
		if node is MeshInstance:
			for i in node.get_surface_material_count():
				storedPlaterLocalizedMeshMaterials.back().append(localizedMaterialInfo.new(nodeOwner.get_path_to(node),node.get_surface_material(i),i))
		for i in node.get_children():
			registerPlaterMaterials(i, nodeOwner)
			
func setPlaterMaterial(plater, newMaterial : Material):#Sets all the materials of a plater to a given material
	if plater.get_class() == "PlaterBase":
		if !storedPlaterFilename.has(plater.get_filename()):
			registerPlater(plater)
		
		for i in storedPlaterLocalizedMeshMaterials[storedPlaterFilename.find(plater.get_filename())]:
			if plater.has_node(i.getPath()):
				if newMaterial == null:
					plater.get_node(i.getPath()).set_surface_material(i.getSurfaceIndex(), i.getMaterial())
				else:
					plater.get_node(i.getPath()).set_surface_material(i.getSurfaceIndex(), newMaterial)

func restorePlaterMaterials(plater):
	Global.setPlaterMaterial(plater, null)
	
#The angle between the Up Vector of a Spatial and the mouse (on-screen angle)
func mouseOnScreenAngleWithSpatial(spat : Spatial, localOrigin : Vector3, localUp : Vector3) -> float:
	var originOnScreen : Vector2 = get_viewport().get_camera().unproject_position(spat.to_global(localOrigin))
	var upOnScreen : Vector2 = get_viewport().get_camera().unproject_position(spat.to_global(localUp))
	var mousePos : Vector2 = get_viewport().get_mouse_position()
	
	return (mousePos - originOnScreen).angle_to(upOnScreen - originOnScreen)
