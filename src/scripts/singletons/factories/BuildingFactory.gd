extends Node

var game_object = preload("res://scenes/GameObject.tscn")
var building_script = preload("res://scripts/gameobject/building/BuildingNode.gd")

func init_building() -> Building:
	var building = game_object.instance()
	building.set_script(building_script)
	return building
	
