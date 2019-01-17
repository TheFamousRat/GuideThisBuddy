
extends Control

var availableNumber : int #Number of available platers
var currentPlater : PackedScene #Current plater the Node references

func _ready():
	availableNumber = 0

func setAvailableNumber(newNumber : int):
	availableNumber = newNumber
	$Button/AvailabNumLabel.set_text("Available : " + str(availableNumber))
	
func getAvailableNumber(newNumber : int):
	return availableNumber
	
func setCurrentPlater(newPlater : PackedScene):
	currentPlater = newPlater
	var temp = currentPlater.instance()
	$Button/PlaterTexture.set_texture(temp.getGUI_Illustration())

func getCurrentPlater():
	return currentPlater