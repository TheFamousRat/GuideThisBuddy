extends "res://nodes/Platers/PlaterBase/PlaterBase.gd"

var suckStrength : float = 1000.0
var changingOrientation : bool = false
var boneTipGlobalCoordinates : Vector3
var mouthAngle : float = 0.0
const ROTATION_INCREMENTS : float = 30.0 *(PI/180)

func _ready():
	changingOrientation = false
	rotateSuckerMouth(mouthAngle)

func clone():
	var copy = self.duplicate()
	copy.mouthAngle = self.mouthAngle
	copy.changingOrientation = false
	return copy

func _process(delta):
	if !disabled:
		var bodies = $SuckerMouth/BodyDetector.get_overlapping_bodies()
		var suckForce = (boneTipGlobalCoordinates - $SuckerMouth/Target.get_global_transform().origin).normalized()
		for i in bodies:
			if i.is_in_group("player"):
				i.add_central_force(suckForce * delta * suckStrength)

func _input(event):
	if changingOrientation:
		if event is InputEventMouseMotion:
			var mouseAngle : float = Global.mouseOnScreenAngleWithSpatial(self, Vector3(0,0,0), Vector3(0,1,0))
			
			mouseAngle *= 2.0
			mouseAngle = ROTATION_INCREMENTS*int(mouseAngle/ROTATION_INCREMENTS)
			mouseAngle = max(-3*PI/4,min(3*PI/4,mouseAngle))
			mouthAngle = mouseAngle
			
			rotateSuckerMouth(mouseAngle)
			
		elif event.is_action_pressed("leftClick"):
			changingOrientation = false

func rotateSuckerMouth(targetAngle : float):
	var rotatedTransform : Transform = Transform.IDENTITY
	rotatedTransform = rotatedTransform.rotated(Vector3(0,1,0), targetAngle/3)
	for i in range(1,3):
		$Model/Armature/Skeleton.set_bone_pose(i, rotatedTransform)
	
	var boneTipTransform : Transform = $Model.get_transform() * $Model/Armature/Skeleton.get_bone_global_pose(4)
	
	$SuckerMouth.set_translation(boneTipTransform.orthonormalized().origin)
	$SuckerMouth.set_rotation(Vector3(0,0,targetAngle/1.5))
	boneTipGlobalCoordinates = $SuckerMouth.get_global_transform().origin

func on_suckerOrientationRequested():
	changingOrientation = true