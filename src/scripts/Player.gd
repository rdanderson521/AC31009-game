extends Node

class_name Player

var units: Array
var buildings: Array
var is_ai: bool
var camera: PlayerCamera
var units_attention_needed: Array

func _init(start_hex,node,ai=false, debug=false):
	if debug:
		print("player init")
	node.add_child(self)
	
	self.units = Array()
	self.buildings = Array()
	
	self.is_ai = ai
	
	self.units.append(UnitFactory.start_units(start_hex,self))
	
	if !ai:
		camera = preload("res://scenes/Camera.tscn").instance()
		self.add_child(camera)
		camera.position = Hex.hex_to_point(start_hex)
		camera.zoom = Vector2(0.3,0.3)
		camera.current = true
		
func turn_start():
	camera.current = true
	for i in units:
		if i.turn_start():
			units_attention_needed.push_back(i)
