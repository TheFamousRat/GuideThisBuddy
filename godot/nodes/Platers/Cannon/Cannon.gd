extends "res://nodes/Platers/PlaterBase/PlaterBase.gd"

export (float) var cannonForce = 100.0

var rotatingCannon : bool = false
const ROTATION_INCREMENTS : float  = 10.0 * (PI/180)

func clone():
	var ret = self.duplicate()
	return ret

func _on_BodyDetector_body_entered(body):
	if body is RigidBody and !disabled:
		body.set_global_transform($RotatedPart/CannonMouth.get_global_transform())
		body.set_linear_velocity(cannonForce*(($RotatedPart.to_global(Vector3(1,0,0)) - $RotatedPart.to_global(Vector3(0,0,0))).normalized()))

func _input(event):
	if rotatingCannon:
		if event is InputEventMouseMotion:
			var mouseAngle = Global.mouseOnScreenAngleWithSpatial(self, Vector3(0,0,0), Vector3(1,0,0))
			
			mouseAngle *= 1.0
			mouseAngle = ROTATION_INCREMENTS*int(mouseAngle/ROTATION_INCREMENTS)
			mouseAngle = max(-3*PI/18,min(3*PI/18,mouseAngle))
			
			var rotationTransform : Transform = Transform.IDENTITY
			$Model/Armature/Skeleton.set_bone_pose(1, rotationTransform.rotated(Vector3(1,0,0), mouseAngle))
			$RotatedPart.set_rotation(rotationTransform.rotated(Vector3(0,0,1), mouseAngle).basis.get_euler())
		elif event.is_action_pressed("leftClick"):
			rotatingCannon = false

func on_rotationRequested():
	rotatingCannon = true