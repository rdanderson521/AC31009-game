extends Node
class_name Player

var units: Array
var buildings: Array
var units_attention_needed: Array
var buildings_attention_needed: Array
var is_turn: bool
var selected_object: GameObject setget set_selected_object
var start_hex: Vector2
var turn: int
var area: Array
var colour: Color
var unit_vis_range: int
var building_vis_range: int
var visible_tiles: Array
var fow: Array
var not_fow: Array


func _init(start_hex:Vector2,debug=true):
	if debug:
		print("player init")
	self.units = Array()
	self.buildings = Array()
	self.fow = Array()
	self.not_fow = Array()
	self.turn = 0
	self.start_hex = start_hex
	self.selected_object = null
	self.units_attention_needed = Array()
	self.buildings_attention_needed = Array()

func _ready():
	print("ready player")
	var start_units = UnitFactory.start_units(self.start_hex,self)
	for i in start_units:
		self.new_unit(i)
	self.fow = GlobalConfig.map.keys().duplicate()
	var start_area_hex = Hex.hex_in_range(4,self.start_hex)
	for i in start_area_hex:
		fow.erase(i)

func reset_visible():
	visible_tiles = Array()
	for i in self.units:
		var hex_area = Hex.hex_in_range(self.unit_vis_range,i.hex_pos)
		hex_area.append(i.hex_pos)
		visible_tiles += hex_area
		visible_tiles.append(i.hex_pos)
		for j in hex_area:
			if fow.erase(j):
				not_fow.append(j)
				
	for i in self.buildings:
		var hex_area = Hex.hex_in_range(self.building_vis_range,i.hex_pos)
		hex_area.append(i.hex_pos)
		visible_tiles += hex_area
		visible_tiles.append(i.hex_pos)
		for j in hex_area:
			if fow.erase(j):
				not_fow.append(j)
		
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
		if obj == selected_object:
			self.selected_object = null
		
func new_building(building:Building):
	self.add_child(building)
	self.buildings.append(building)
	self.reset_visible()
	if building.turn_start():
		self.buildings_attention_needed.append(building)
	
func new_unit(unit:Unit):
	self.add_child(unit)
	self.units.append(unit)
	self.visible_tiles += Hex.hex_in_range(self.unit_vis_range,unit.hex_pos)
	self.reset_visible()
	if unit.turn_start():
		self.units_attention_needed.append(unit)

func unit_moved(unit:Unit,from:Vector2,to:Vector2):
	if unit in self.units:
		var old_visible = Hex.hex_in_range(self.unit_vis_range,from) 
		old_visible.append(from)
		var new_visible = Hex.hex_in_range(self.unit_vis_range,to)
		new_visible.append(to)
		
		for i in old_visible:
			if i in new_visible:
				new_visible.erase(i)
			else:
				self.visible_tiles.erase(i)
				
		for i in new_visible:
			self.visible_tiles.append(i)
			if i in self.fow:
				self.fow.erase(i)
	

