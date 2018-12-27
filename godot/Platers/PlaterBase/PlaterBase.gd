extends Spatial

func is_type(type): 
	return type == "PlaterBase" or .is_type(type)
	
func get_type(): 
	return "PlaterBase"
