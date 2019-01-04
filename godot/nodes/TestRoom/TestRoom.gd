tool

extends Node

func _process(delta):
	var xVec : Vector3
	var yVec : Vector3
	var zVec : Vector3
	xVec = $Spatial/xAxis.get_global_transform().origin - $Spatial/origin.get_global_transform().origin
	yVec = $Spatial/yAxis.get_global_transform().origin - $Spatial/origin.get_global_transform().origin
	zVec = $Spatial/zAxis.get_global_transform().origin - $Spatial/origin.get_global_transform().origin
	$u.translation = $i.translation + $i.cast_to
	$u.cast_to = bounceVect($i.cast_to,xVec,yVec,zVec)

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
