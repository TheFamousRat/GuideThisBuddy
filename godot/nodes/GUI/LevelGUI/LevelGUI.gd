extends Control

func _on_retry_pressed():
	get_node(Global.mainPath).reloadCurrentLevel()
	self.queue_free()
