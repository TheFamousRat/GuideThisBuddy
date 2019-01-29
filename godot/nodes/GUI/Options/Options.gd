extends WindowDialog

func _ready():
	self.popup()

func _on_Quit_pressed():
	self.queue_free()

func _on_Antialiasing_item_selected(ID):
	match $Antialiasing.get_item_text(ID):
		"Disabled":
			get_viewport().msaa = Viewport.MSAA_DISABLED
		"x2":
			get_viewport().msaa = Viewport.MSAA_2X
		"x4":
			get_viewport().msaa = Viewport.MSAA_4X
		"x8":
			get_viewport().msaa = Viewport.MSAA_8X
		"x16":
			get_viewport().msaa = Viewport.MSAA_16X