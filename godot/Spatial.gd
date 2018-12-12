tool
extends Spatial

export (float) var theta = 0.0 setget updateTheta
export (float) var phi = 0.0 setget updatePhi

func _ready():
	pass

func updateTheta(value):
	theta = value

	if self.has_node("xRay") and self.has_node("yRay") and self.has_node("zRay"):
		$yRay.cast_to = Vector3(sin(theta)*cos(phi+PI/2),cos(theta),sin(theta)*sin(phi+PI/2))
		$zRay.cast_to = Vector3(sin(theta+PI/2)*cos(phi+PI/2),cos(theta+PI/2),sin(theta+PI/2)*sin(phi+PI/2))
		print(predictAngles())

		
func updatePhi(value):
	phi = value
	if self.has_node("xRay") and self.has_node("yRay") and self.has_node("zRay"):
		$yRay.cast_to = Vector3(sin(theta)*cos(phi+PI/2),cos(theta),sin(theta)*sin(phi+PI/2))
		$zRay.cast_to = Vector3(sin(theta+PI/2)*cos(phi+PI/2),cos(theta+PI/2),sin(theta+PI/2)*sin(phi+PI/2))
		print(predictAngles())
		
func predictAngles():
	var predictedTheta = 0.0
	var predictedPhi = 0.0
	
	predictedTheta = acos($yRay.cast_to.y)
	
	return predictedTheta == theta and predictedPhi == phi
