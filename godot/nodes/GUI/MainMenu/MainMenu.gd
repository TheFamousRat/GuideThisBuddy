extends Control

func _on_Start_pressed():
	get_node(Global.mainPath).loadLevel("res://nodes/Levels/Level1/Level1.tscn")
	self.queue_free()


func _on_Quit_pressed():
	$ConfirmQuit.popup()


func _on_ConfirmQuit_confirmed():
	get_tree().quit()


func _on_Options_pressed():
	get_parent().loadGui(get_parent().options)
