extends Control

export (PackedScene) var mainMenu
export (PackedScene) var platerPlacement
export (PackedScene) var levelGUI
export (PackedScene) var options

func loadGui(guiToLoad : PackedScene):
	#Loading the level and adding it as a child
	var newGui = guiToLoad.instance()
	self.add_child(newGui)
