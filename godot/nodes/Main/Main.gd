extends Node

func _ready():
	$Slime.hide()
	$Slime.set_sleeping(true)
	
	$GUI.loadGui($GUI.mainMenu)

func loadLevel(levelPath : String):
	#Loading the new level and adding it as a child
	var newLevel = load(levelPath).instance()
	$CurrentLevel.add_child(newLevel)
	
	launchPlaterPlacement()
	
func reloadCurrentLevel():
	$CurrentLevel.get_child(0).reload()
	$Slime.set_sleeping(false)
	
	launchPlaterPlacement()

func launchPlaterPlacement():
	#This method prepares the level for the plater placement phase
	$Slime.set_sleeping(true)
	$Slime.set_global_transform($CurrentLevel.get_child(0).get_node("PlayerStart").get_global_transform())
	$Slime.set_visible(true)
	$Slime.launchAnimation("Idle", true, 1.0)
	
	$GameCamera.centerOn($Slime)
	
	$GUI.loadGui($GUI.platerPlacement)
	
	$CurrentLevel.get_child(0).set_running(false)
	
	$GUI.getGUI($GUI.platerPlacement).connect("selectedPlater", $CurrentLevel.get_child(0), "placeNewPlater")
	
func launchLevel():
	$Slime.set_sleeping(false)
	
	$GameCamera.setTarget($Slime)
	
	$GUI.loadGui($GUI.levelGUI)
	
	$CurrentLevel.get_child(0).set_running(true)

func levelComplete():#Method giving procedure when player won a level
	$GUI.clearCurrentGui()
	$GUI.loadGui($GUI.levelComplete)
	
func getLevelAvailablePlaters():
	return $CurrentLevel.get_child(0).getAvailablePlaters()
	
func _process(delta):
	pass