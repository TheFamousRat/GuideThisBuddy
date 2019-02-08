extends "res://nodes/Platers/PlaterBase/PlaterBase.gd"

var suckForce : Vector3 = Vector3(0,0,0)
var suckStrength : float = 500.0
var changingOrientation : bool = false
const ROTATION_INCREMENTS : float = 30.0 *(PI/180)

signal orientationDone

func _ready():
	suckForce = ($Origin.get_global_transform().origin - $Target.get_global_transform().origin).normalized()
	changingOrientation = false

func _process(delta):
	var bodies = $BodyDetector.get_overlapping_bodies()
	for i in bodies:
		if i.is_in_group("player"):
			i.add_central_force(suckForce * delta * suckStrength)

func _input(event):
	if changingOrientation:
		if event is InputEventMouseMotion:
			var originOnScreen : Vector2 = get_viewport().get_camera().unproject_position($Origin.get_global_transform().origin)
			var upOnScreen : Vector2 = get_viewport().get_camera().unproject_position($Up.get_global_transform().origin)
			var mousePos : Vector2 = get_viewport().get_mouse_position()
			var mouseAngle : float = (mousePos - originOnScreen).angle_to(upOnScreen - originOnScreen)
			mouseAngle *= 1.4
			
			mouseAngle = ROTATION_INCREMENTS*int(mouseAngle/ROTATION_INCREMENTS)
			mouseAngle = max(-3*PI/4,min(3*PI/4,mouseAngle))

			
			var rotatedTransform : Transform = Transform.IDENTITY
			rotatedTransform = rotatedTransform.rotated(Vector3(0,1,0), mouseAngle/3)
			for i in range(1,3):
				$Model/Armature/Skeleton.set_bone_pose(i, rotatedTransform)
			
		elif event.is_action_pressed("leftClick"):
			emit_signal("orientationDone")
			changingOrientation = false

func on_suckerOrientationRequested():
	changingOrientation = true