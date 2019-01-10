extends WindowDialog

func _ready():
	self.popup()

func _on_Quit_pressed():
	self.queue_free()
