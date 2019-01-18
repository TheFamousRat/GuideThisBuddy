
extends Control

var availableNumber : int = 0 #Number of available platers
var currentPlater : PackedScene #Current plater the Node references

signal platerInterfacePressed

func _ready():
	pass

func setAvailableNumber(newNumber : int):
	availableNumber = newNumber
	$TextureButton/AvailabNumLabel.set_text("Available : " + str(availableNumber))
	
func getAvailableNumber():
	return availableNumber
	
func setCurrentPlater(newPlater : PackedScene):
	currentPlater = newPlater
	var temp = currentPlater.instance()
	$TextureButton/PlaterTexture.set_texture(temp.getGUI_Illustration())

func getCurrentPlater():
	return currentPlater

func _on_TextureButton_pressed():
	emit_signal('platerInterfacePressed', self)
