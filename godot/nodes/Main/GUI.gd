extends Control

func loadGui(guiToLoad : String):
	#Unloading the previous level
	while self.get_child_count() != 0:
		self.remove_child(self.get_child(0))
	
	#Loading the level and adding it as a child
	var newGui = load(guiToLoad).instance()
	self.add_child(newGui)
