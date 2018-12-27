tool

extends "res://Platers/PlaterBase/PlaterBase.gd"

export (float) var cannonForce = 2000.0

var propulsedBodies : Array

func _ready():
	propulsedBodies = Array()

func _process(delta):
	var bodies = $BodyDetector.get_overlapping_bodies()
	for i in bodies:
		if i is RigidBody and !propulsedBodies.has(i.get_path()):
			i.add_central_force(cannonForce*(($Position3D.get_global_transform().origin - self.get_global_transform().origin).normalized()))
			propulsedBodies.append(i.get_path())
			$AnimationPlayer.play("explosion")