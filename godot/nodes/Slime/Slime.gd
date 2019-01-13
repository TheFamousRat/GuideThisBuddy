extends RigidBody

var loopingAnim : bool = false
var lastAnimSpeed : float = 0.0
var idleLoops : int = 0

func _process(delta):
	pass
	
func _ready():
	idleLoops = 0

func set_sleeping(sleeping : bool):
	if sleeping:
		self.set_mode(RigidBody.MODE_STATIC)
	else:
		self.set_mode(RigidBody.MODE_RIGID)
		
func _integrate_forces(state):
	if state.get_linear_velocity() == Vector3(0,0,0):
		state.set_linear_velocity(Vector3(0,0.0000002,0))
		
func launchAnimation(animationName : String, looping : bool = false, animationSpeed : float = 1.0):
	loopingAnim = looping
	lastAnimSpeed = animationSpeed
	$Model/AnimationPlayer.play(animationName, -1, animationSpeed)

func _on_AnimationPlayer_animation_finished(anim_name):
	if loopingAnim:
		if anim_name.begins_with("Idle"):
			idleLoops+=1
			if idleLoops >= 10:#Playing a random other idle animation
				idleLoops = 0
				$Model/AnimationPlayer.play("IdleLookAround", -1, lastAnimSpeed)
			else:
				$Model/AnimationPlayer.play("Idle", -1, lastAnimSpeed)
		else:
			$Model/AnimationPlayer.play(anim_name, -1, lastAnimSpeed)