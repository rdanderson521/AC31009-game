extends Node

var hex = preload("res://HexOperations.gd")

class_name Player

var sprite_template = preload("res://spriteTemplate.tscn")
var units
var buildings
var is_ai

#init(name, health, move_range, damage, damage_range, can_build, can_build_city, texture, hex_pos):

func _init(start_hex,units_arr,node,ai=false):
	print("player init")
	node.add_child(self)
	self.units = Array()
	self.buildings = Array()
	
	self.is_ai = ai
	var start_locations = hex.hex_in_range(1,start_hex)
	start_locations.shuffle()
	for i in units_arr:
		print("player unit: " + str(i))
		if i.has("start"):
			print("has start")
			for j in range (0,i["start"]):
				print("idx: " + str(j))
				if !start_locations.empty():
					var start_unit = sprite_template.instance()
					print("pls")
					start_unit.init(i["name"],i["health"],i["move_range"],i["damage"],i["damage_range"],
					i["can_build_districts"],i["can_build_cities"],i["texture"],start_locations.pop_back())
					print("wtf")
					self.units.push_back(start_unit)
					self.add_child(start_unit)
					
					
