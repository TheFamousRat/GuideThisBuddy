tool

extends Node

export (Array) var availablePlaters setget availablePlaterArrayChecker

"""
To do a new level, one has to do the following :
	1/Create new scene inherited from LevelBase
	2/Set the "available platers" array. It functions
	like that : the size of the array is always even, 
	because the instructions are given 2-by-2.
	In a couple, the first cell is always of type
	Object, while the second is of type int.
	The first loads the plater and his whole scene,
	while the int gives the number of such platers
	that can be placed in the level.
	3/Do the layout as you please...
	4/Don't forget to give the player arrival area at 
	least one collisionShape !
	5/You're good to go
	
	Note :
		If you want to personalize the script of your
		level, don't forget to inherit it from this one,
		don't touch it directly...
"""

"""
Needed variables :
	Level layout
"""

func availablePlaterArrayChecker(newArray : Array):
	var platersArray : Array

	if newArray != null:
		if newArray.size() % 2 == 1 && newArray.size() > availablePlaters.size():
			availablePlaters = newArray.duplicate()
			availablePlaters.append(int(0))
		elif newArray.size() % 2 == 1 && newArray.size() < availablePlaters.size():
			availablePlaters = newArray.duplicate()
			availablePlaters.remove(availablePlaters.size() - 1)
		else:
			availablePlaters = newArray.duplicate()
		
		for i in availablePlaters.size():
			if i%2 == 0:
				if availablePlaters[i] is PackedScene and availablePlaters[i] != null:
					pass
				else:
					availablePlaters[i] = PackedScene.new()
			elif i%2 == 1 and !(availablePlaters[i] is int):
				availablePlaters[i] = int(0)