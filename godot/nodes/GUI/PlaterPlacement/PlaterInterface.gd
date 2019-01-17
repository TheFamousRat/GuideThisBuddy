
extends Control

var availableNumber : int #Number of available platers

func _ready():
	availableNumber = 0

func setAvailableNumber(newNumber : int):
	availableNumber = newNumber
	$Button/AvailabNumLabel.set_text("Available : " + str(availableNumber))
	
func getAvailableNumber(newNumber : int):
	return availableNumber