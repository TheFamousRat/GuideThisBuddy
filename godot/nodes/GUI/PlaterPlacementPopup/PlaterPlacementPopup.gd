extends "res://nodes/GUI/SpatialStalker.gd"

var center : Vector2

var showingAnimDuration : float = 0.1
var hidingAnimDuration : float = 0.1
var visiblePlatersCount : int

export (float) var radius = 80.0
export (float) var minAngle = 0.0
export (float) var maxAngle = 2 * PI

signal translationRequested
signal rotationRequested
signal deletionRequested
signal suckerOrientation

#Don't bother positioning the childs of OptionButtons : they WILL get repositioned by the script

func _ready():
	set_process(get_tree().get_edited_scene_root() == null)
	center = self.get_size() * 0.5
	$hidingTimer.set_wait_time(hidingAnimDuration)
	
	updateVisibleChildrenCount()
	
	for i in $OptionButtons.get_child_count():
		var newTween : Tween = Tween.new()
		$Tweens.add_child(newTween)
			
	if self.is_visible():
		self.show()

func updateVisibleChildrenCount():
	visiblePlatersCount = 0
	
	for i in $OptionButtons.get_children():
		if i.is_visible():
			visiblePlatersCount += 1

func setStalkedSpatial(newSpatial):
	.setStalkedSpatial(newSpatial)
	#Update the visibility parameters of the childs
	if newSpatial.get_class() == "PlaterBase":
		$OptionButtons/Translation.set_visible(newSpatial.enabledTranslation)
		$OptionButtons/Rotation.set_visible(newSpatial.enabledRotation)
		$OptionButtons/SuckerOrientation.set_visible(newSpatial.get_filename().to_upper().find("SUCKER") != -1)
	updateVisibleChildrenCount()
	
func _process(delta):
	if get_viewport().get_camera().get_projection() == Camera.PROJECTION_ORTHOGONAL:
		self.set_scale(Vector2(1,1)*8.0/get_viewport().get_camera().get_size())
	else:
		self.set_scale(Vector2(1,1)*16.0/get_viewport().get_camera().getTargetDist())

func show():
	self.set_visible(true)
	
	var childNumber : int = 0
	
	for i in $Tweens.get_child_count():
		i = Tween.new()
	
	for popupChild in $OptionButtons.get_children():
		if popupChild.is_visible():
			var circlePos : float = minAngle + (maxAngle - minAngle) * childNumber / max(1.0, visiblePlatersCount-1)
			var childOffsetedCenter : float = center - 0.5 * popupChild.get_size() * popupChild.get_scale()#Made so that the children are correctly centered
			$Tweens.get_child(childNumber).interpolate_property(popupChild, "rect_position", childOffsetedCenter, childOffsetedCenter + radius * Vector2(cos(circlePos),-sin(circlePos)), showingAnimDuration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			childNumber += 1
	
	for i in $Tweens.get_children():
		i.start()

func hide():
	var childNumber : int = 0

	for i in $Tweens.get_child_count():
		i = Tween.new()
	
	for popupChild in $OptionButtons.get_children():
		if popupChild.is_visible():
			var circlePos : float = minAngle + (maxAngle - minAngle) * childNumber / max(1.0, visiblePlatersCount-1)
			var childOffsetedCenter : float = center - 0.5 * popupChild.get_size() * popupChild.get_scale()
			$Tweens.get_child(childNumber).interpolate_property(popupChild, "rect_position", childOffsetedCenter + radius * Vector2(cos(circlePos),-sin(circlePos)), childOffsetedCenter, hidingAnimDuration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
			childNumber += 1
			
	for i in $Tweens.get_children():
		i.start()

	$hidingTimer.start()

func closingAnimDone():
	self.set_visible(false)

func _on_Translation_pressed():
	emit_signal("translationRequested")

func _on_Rotation_pressed():
	emit_signal("rotationRequested")

func _on_Delete_pressed():
	emit_signal("deletionRequested")

func _on_SuckerOrientation_pressed():
	emit_signal("suckerOrientation")

func _on_ColorRect_gui_input(event):
	if event.is_action_pressed("leftClick"):
		self.hide()
