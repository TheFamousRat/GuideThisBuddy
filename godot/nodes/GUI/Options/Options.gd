extends WindowDialog

func _ready():
	self.popup()

func _on_Quit_pressed():
	self.queue_free()

func _on_Antialiasing_item_selected(ID):
	get_viewport().set_antiali
