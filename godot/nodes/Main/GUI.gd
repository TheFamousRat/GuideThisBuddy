extends Control

export (PackedScene) var mainMenu
export (PackedScene) var platerPlacement

func loadGui(guiToLoad : PackedScene):
	#Unloading the previous level
	while self.get_child_count() != 0:
		self.remove_child(self.get_child(0))
	
	#Loading the level and adding it as a child
	var newGui = guiToLoad.instance()
	self.add_child(newGui)
