extends Control

func _on_Button_pressed():
	get_node(Global.mainPath).loadLevel("res://nodes/Levels/TestLevel/TestLevel.tscn")
	self.queue_free()