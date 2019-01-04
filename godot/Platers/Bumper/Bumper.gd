extends "res://Platers/PlaterBase/PlaterBase.gd"

var bumpStrength : float = 100.0
var launchedBodies : Array

func _process(delta):
	var bodies = $BodyDetector.get_overlapping_bodies()
	for i in bodies:
		if i.is_in_group("player") and !launchedBodies.has(i.get_path()):
			var xVec : Vector3
			var yVec : Vector3
			var zVec : Vector3
			xVec = $Spatial/xAxis.get_global_transform().origin - $Spatial/origin.get_global_transform().origin
			yVec = $Spatial/yAxis.get_global_transform().origin - $Spatial/origin.get_global_transform().origin
			zVec = $Spatial/zAxis.get_global_transform().origin - $Spatial/origin.get_global_transform().origin
			i.add_force(bumpStrength * bounceVect(i.linear_velocity,xVec,yVec,zVec),Vector3(0,0,0))
			launchedBodies.append(i.get_path())
			
func bounceVect(inputVec : Vector3, xAxis : Vector3, yAxis : Vector3, zAxis : Vector3):
	var a : float = xAxis.x
	var b : float = xAxis.y
	var c : float = xAxis.z
	var d : float = yAxis.x
	var e : float = yAxis.y
	var f : float = yAxis.z
	var g : float = zAxis.x
	var h : float = zAxis.y
	var i : float = zAxis.z
	var k : float = inputVec.x
	var l : float = inputVec.y
	var m : float = inputVec.z
	
	var beta : float
	
	#yum
	beta = (a*l-k*b+(m*(a*e-d*b)+c*(l*d-k*e)+f*(k*b-a*l)) / (c*(h*d-g*e)+f*(g*b-h*a)-i)*(g*b-h*a))/(d*b-a*e)
	
	return (2.0 * (beta * yAxis) + inputVec)