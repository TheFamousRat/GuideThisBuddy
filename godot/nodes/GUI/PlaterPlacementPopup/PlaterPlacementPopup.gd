extends "res://nodes/GUI/SpatialStalker.gd"

var center : Vector2

var showingAnimDuration : float = 0.3
var hidingAnimDuration : float = 0.3
var initialPosArray : PoolVector2Array#Initial positions of all Control nodes

func _ready():
	center = self.get_size() * 0.5
	$hidingTimer.set_wait_time(hidingAnimDuration)
	
	for popupChild in self.get_children():
		if popupChild.is_class("Control"):
			var newTween : Tween = Tween.new()
			$Tweens.add_child(newTween)
			initialPosArray.append(popupChild.get_position())
			
	if self.is_visible():
		self.show()

func show():
	self.set_visible(true)
	
	var childNumber : int = 0
	for popupChild in self.get_children():
		if popupChild.is_class("Control"):
			$Tweens.get_child(childNumber).interpolate_property(popupChild, "rect_position", center, initialPosArray[childNumber], showingAnimDuration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			childNumber += 1
	
	for i in $Tweens.get_children():
		i.start()

func hide():
	var childNumber : int = 0
	for popupChild in self.get_children():
		if popupChild.is_class("Control"):
			$Tweens.get_child(childNumber).interpolate_property(popupChild, "rect_position", initialPosArray[childNumber], center, hidingAnimDuration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			childNumber += 1
			
	for i in $Tweens.get_children():
		i.start()

	$hidingTimer.start()

func closingAnimDone():
	self.set_visible(false)

