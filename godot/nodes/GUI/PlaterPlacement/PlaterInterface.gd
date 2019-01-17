
extends Control

func setAvailableNumber(newNumber : int):
	$Button/AvailabNumLabel.set_text("Available : " + str(newNumber))