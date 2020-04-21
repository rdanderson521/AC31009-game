extends Node

class_name Player

var units: Array
var buildings: Array
var is_ai: bool
var camera: PlayerCamera
var units_attention_needed: Array
var is_turn: bool
var selected_object: GameObject setget set_selected_object
var start_hex: Vector2
var turn: int
var mode: int
var area: Array
var colour: Color
var fow: Array
var visible_tiles: Array
var fow_canvas: Node2D
# 0.37

const DEFAULT = 0
const MOVE = 1
const ATTACK = 3
const BUILD = 5


func _init(start_hex:Vector2,ai ,debug=true):
	if debug:
		print("player init")
	self.units = Array()
	self.buildings = Array()
	self.turn = 0
	self.is_ai = ai
	self.start_hex = start_hex
	self.selected_object = null

func _ready():
	self.units += UnitFactory.start_units(self.start_hex,self)
	for i in self.units:
		self.add_child(i)
	self.fow = GlobalConfig.map.keys()
	var start_area_hex = Hex.hex_in_range(4,self.start_hex)
	start_area_hex.append(self.start_hex)
	for i in start_area_hex:
		fow.erase(i)
	self.reset_visible_tiles()
	if !is_ai:
		fow_canvas.draw_fow(fow)

func reset_visible_tiles():
	for i in self.units:
		visible_tiles += Hex.hex_in_range(2,i.hex_pos)
		visible_tiles.append(i.hex_pos)
		
	for i in self.buildings:
		visible_tiles += Hex.hex_in_range(3,i.hex_pos)
		visible_tiles.append(i.hex_pos)
		
func unit_start_build(building_name:String):
	if is_turn:
		if selected_object is Unit:
			if selected_object.can_build(building_name):
				selected_object.start_build(building_name)

func set_selected_object(obj:GameObject):
	if obj is Unit:
		selected_object = obj
		SignalManager.building_unselected()
		SignalManager.unit_selected(obj)
	elif obj is Building:
		selected_object = obj
		SignalManager.unit_unselected()
		SignalManager.building_selected(obj)
	else:
		SignalManager.unit_unselected()
		


#func turn_start():
#	is_turn = true
#	self.turn += 1
#	if !is_ai:
#		camera.make_current()
#		self.fow_canvas.visible = true
#		$Camera2D/CanvasLayer/MainGui.turn_started(self.turn)
#		$Camera2D/CanvasLayer/MainGui.visible = true
#	if !units.empty():
#		for i in self.units:
#			print("unit:" + str(i))
#			if i.turn_start():
#				units_attention_needed.push_back(i)
#
#func turn_end():
#	if is_turn:
#		is_turn = false
#		selected_object = null
#		$Camera2D/CanvasLayer/MainGui.visible= false
#		$Camera2D/CanvasLayer/MainGui.turn_ended()
#		SignalManager.player_turn_ended(self)
#		self.fow_canvas.visible = false

func kill(obj:GameObject):
	if obj is Unit:
		units.erase(obj)
		if obj in units_attention_needed:
			units_attention_needed.erase(obj)
		if obj == selected_object:
			self.selected_object = null
			
	elif obj is Building:
		buildings.erase(obj)
		
func new_building(building:Building):
	self.add_child(building)
	self.buildings.append(building)
	self.visible_tiles += Hex.hex_in_range(3,building.hex_pos)

func unit_moved(unit:Unit,from:Vector2,to:Vector2):
	print("testtest2")
	if unit in self.units:
		var old_visible = Hex.hex_in_range(2,from) 
		old_visible.append(from)
		var new_visible = Hex.hex_in_range(2,to)
		new_visible.append(to)
		print ("unit moved")
		
		for i in old_visible:
			if i in new_visible:
				new_visible.erase(i)
			else:
				self.visible_tiles.erase(i)
				
		for i in new_visible:
			self.visible_tiles.append(i)
			if i in self.fow:
				self.fow.erase(i)
	self.fow_canvas.fog_of_war = self.fow
	self.fow_canvas.visible_tiles = self.visible_tiles
	self.fow_canvas.draw()
	

