extends Control

signal launch_level

func _ready():
	pass

func _on_Button_pressed():
	$Button.queue_free()
	emit_signal("launch_level", "res://Levels/TestLevel/TestLevel.tscn")
