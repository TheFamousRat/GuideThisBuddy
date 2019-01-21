tool
extends "res://nodes/GUI/SpatialStalker.gd"

var center : Vector2

var showingAnimDuration : float = 0.1
var hidingAnimDuration : float = 0.1
var initialPosArray : PoolVector2Array#Initial positions of all Control nodes

export (bool) var showTranslation setget translationVisibility
export (bool) var showRotation setget rotationVisibility

func _ready():
	set_process(get_tree().get_edited_scene_root() == null)
	center = self.get_size() * 0.5
	$hidingTimer.set_wait_time(hidingAnimDuration)
	
	for popupChild in self.get_children():
		if popupChild.is_class("Control"):
			if popupChild.is_visible():
				var newTween : Tween = Tween.new()
				$Tweens.add_child(newTween)
				initialPosArray.append(popupChild.get_position())
			
	if self.is_visible():
		self.show()

func _process(delta):
	self.set_scale(Vector2(1,1)*8.0/get_viewport().get_camera().get_size())

func show():
	self.set_visible(true)
	
	var childNumber : int = 0
	for popupChild in self.get_children():
		if popupChild.is_class("Control"):
			if popupChild.is_visible():
				$Tweens.get_child(childNumber).interpolate_property(popupChild, "rect_position", center, initialPosArray[childNumber], showingAnimDuration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				childNumber += 1
	
	for i in $Tweens.get_children():
		i.start()

func hide():
	var childNumber : int = 0
	for popupChild in self.get_children():
		if popupChild.is_class("Control"):
			if popupChild.is_visible():
				$Tweens.get_child(childNumber).interpolate_property(popupChild, "rect_position", initialPosArray[childNumber], center, hidingAnimDuration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
				childNumber += 1
			
	for i in $Tweens.get_children():
		i.start()

	$hidingTimer.start()

func closingAnimDone():
	self.set_visible(false)

func translationVisibility(newVisibility : bool):
	showTranslation = newVisibility
	$Translation.set_visible(newVisibility)
	
func rotationVisibility(newVisibility : bool):
	showRotation = newVisibility
	$Rotation.set_visible(newVisibility)