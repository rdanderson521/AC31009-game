extends Node
class_name Player

var units: Array
var buildings: Array
var cities: Array
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

const START_AREA_SIZE = 4

func _init(start_hex:Vector2):
	self.units = Array()
	self.buildings = Array()
	self.cities = Array()
	self.fow = Array()
	self.not_fow = Array()
	self.turn = 0
	self.start_hex = start_hex
	self.selected_object = null
	self.units_attention_needed = Array()
	self.buildings_attention_needed = Array()
	SignalManager.connect("kill_unit",self,"kill")
	SignalManager.connect("kill_building",self,"kill")

func _ready():
	var start_units = UnitFactory.start_units(self.start_hex,self)
	for i in start_units:
		self.new_unit(i)
	self.fow = GlobalConfig.map.keys().duplicate()
	var start_area_hex = Hex.hex_in_range(START_AREA_SIZE,self.start_hex)
	for i in start_area_hex:
		fow.erase(i)
		not_fow.append(i)

func reset_visible():
	self.visible_tiles = Array()
	for i in self.units:
		var hex_area = Hex.hex_in_range(self.unit_vis_range,i.hex_pos)
		self.visible_tiles += hex_area
		self.visible_tiles.append(i.hex_pos)
		for j in hex_area:
			if self.fow.has(j):
				self.fow.erase(j)
				self.not_fow.append(j)
				
	for i in self.buildings:
		var hex_area = Hex.hex_in_range(self.building_vis_range,i.hex_pos)
		self.visible_tiles += hex_area
		self.visible_tiles.append(i.hex_pos)
		for j in hex_area:
			if self.fow.has(j):
				self.fow.erase(j)
				self.not_fow.append(j)
		
func set_selected_object(obj:GameObject):
	if obj is Unit:
		SignalManager.building_unselected()
		SignalManager.unit_selected(obj)
	elif obj is Building:
		SignalManager.unit_unselected()
		SignalManager.building_selected(obj)
	else:
		SignalManager.unit_unselected()
		SignalManager.building_unselected()
	selected_object = obj
		


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
	if obj.get_parent() == self:
		if obj is Unit:
			self.units.erase(obj)
			if obj in self.units_attention_needed:
				self.units_attention_needed.erase(obj)
			if obj == self.selected_object:
				self.selected_object = null
		elif obj is Building:
			self.buildings.erase(obj)
			if obj == self.selected_object:
				self.selected_object = null
			if obj is City:
				self.cities.erase(obj)
		self.reset_visible()
		
func new_building(building:Building):
	self.buildings.append(building)
	GlobalConfig.building_tiles[building.hex_pos] = building
	if building is City:
		GlobalConfig.city_tiles[building.hex_pos] = building
		self.cities.append(building)
	self.visible_tiles += Hex.hex_in_range(self.building_vis_range,building.hex_pos)
	if building.turn_start():
		self.buildings_attention_needed.append(building)
	
func new_unit(unit:Unit):
	self.units.append(unit)
	self.visible_tiles += Hex.hex_in_range(self.unit_vis_range,unit.hex_pos)
	if unit.turn_start():
		self.units_attention_needed.append(unit)

func unit_moved(unit:Unit,from:Vector2,to:Vector2):
	if unit in self.units:
		var old_visible = Hex.hex_in_range(self.unit_vis_range,from) 
		var new_visible = Hex.hex_in_range(self.unit_vis_range,to)
		
		for i in old_visible:
			if i in new_visible:
				new_visible.erase(i)
			else:
				self.visible_tiles.erase(i)
				
		for i in new_visible:
			self.visible_tiles.append(i)
			if self.fow.has(i):
				self.fow.erase(i)
				self.not_fow.append(i)
	

