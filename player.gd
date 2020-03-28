extends Object

class_name Player

var units
var buildings
var is_ai

func _init(ai,start_hex,units_arr):
	self.units = Array()
	self.buildings = Array()
	
	self.is_ai = ai
	
	for i in units_arr:
		if i.has("start"):
			for j in range (0,i[start]):
				
