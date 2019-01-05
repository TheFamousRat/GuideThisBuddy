extends Control

func _on_Button_pressed():
	get_node("/root/Main").loadLevel("res://nodes/Levels/TestLevel/TestLevel.tscn")
