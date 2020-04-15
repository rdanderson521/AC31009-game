extends Node

class_name Player

var units
var buildings
var is_ai

func _init(start_hex,node,ai=false, debug=false):
	if debug:
		print("player init")
	node.add_child(self)
	
	self.units = Array()
	self.buildings = Array()
	
	self.is_ai = ai
	
	self.units.append(UnitFactory.start_units(start_hex))
