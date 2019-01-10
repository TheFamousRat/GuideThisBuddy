extends Control

func _on_Start_pressed():
	get_node(Global.mainPath).loadLevel("res://nodes/Levels/TestLevel/TestLevel.tscn")
	self.queue_free()


func _on_Quit_pressed():
	$ConfirmQuit.popup()


func _on_ConfirmQuit_confirmed():
	get_tree().quit()
