extends Spatial

func _ready():
	$Slime.hide()
	$Slime.set_sleeping(true)
	
	$GUI.loadGui($GUI.mainMenu)

func loadLevel(levelPath : String):
	#Loading the new level and adding it as a child
	var newLevel = load(levelPath).instance()
	$CurrentLevel.add_child(newLevel)
	
	applyLevelParameters()
	
	#Preparing the start of the Plater placement phase
	$Slime.show()
	$GUI.loadGui($GUI.platerPlacement)
	$GameCamera.centerOn($Slime)
	
func reloadCurrentLevel():
	$CurrentLevel.get_child(0).reload()

func applyLevelParameters():
	$Slime.translation = $CurrentLevel.get_child(0).get_node("PlayerStart").translation

func launchLevel():
	$Slime.set_sleeping(false)
	$GameCamera.setTarget($Slime)
	$GUI.loadGui($GUI.levelGUI)
	
func getLevelAvailablePlaters():
	return $CurrentLevel.get_child(0).getAvailablePlaters()
	
func _process(delta):
	pass