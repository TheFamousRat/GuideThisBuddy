extends "res://nodes/LevelBase/LevelBase.gd"

func _ready():
	availablePlaters.append(load("res://nodes/Platers/Pusher/Pusher.tscn"))
	availablePlaters.append(1)
	
