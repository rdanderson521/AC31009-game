extends Node

var game_object = preload("res://scenes/GameObject.tscn")
var unit_script = preload("res://scripts/UnitNode.gd")

func init_unit() -> Unit:
	var unit = game_object.instance()
	unit.set_script(unit_script)
	return unit
	

