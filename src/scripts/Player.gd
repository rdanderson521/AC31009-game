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

const DEFAULT = 0
const MOVE = 1
const ATTACK = 3
const BUILD = 5


func _init(start_hex,node,ai=false, debug=false):
	if debug:
		print("player init")
	#node.add_child(self)
	
	self.units = Array()
	self.buildings = Array()
	self.turn = 0
	
	self.start_hex = start_hex
	
	self.selected_object = null
	
	self.is_ai = ai
	self.is_turn = false
	
	if !ai:
#		SignalManager.connect("end_turn_btn_click",self,"turn_end")
		SignalManager.connect("mouse_left_game_obj",self,"game_object_clicked_left")
		SignalManager.connect("mouse_right_game_obj",self,"game_object_clicked_right")
		SignalManager.connect("mouse_left_tilemap",self,"tilemap_clicked_left")
		SignalManager.connect("mouse_right_tilemap",self,"tilemap_clicked_right")
		SignalManager.connect("build_btn_click",self,"unit_start_build")
		camera = preload("res://scenes/Camera.tscn").instance()
		self.add_child(camera)
		camera.position = Hex.hex_to_point(start_hex)
		camera.zoom = Vector2(0.3,0.3)
		$Camera2D/CanvasLayer/MainGui.visible = false
		
func _ready():
	self.units += UnitFactory.start_units(self.start_hex,self)
	for i in self.units:
		self.add_child(i)
		
func unit_start_build(building):
	if selected_object is Unit:
		if selected_object.can_build(building):
			selected_object.start_build(building)

func set_selected_object(obj):
	if obj is Unit:
		selected_object = obj
		SignalManager.unit_selected(obj)
	elif obj is Building:
		pass
	else:
		SignalManager.unit_unselected()
		
		
func game_object_clicked_left(obj):
	if is_turn:
		if obj.get_parent() == self:
			self.selected_object = obj
			self.mode = 0
		elif selected_object != null and mode == ATTACK:
			if selected_object is Unit:
				selected_object.attack(obj)
			elif selected_object is Building:
				if selected_object.in_range(obj):###########make in range func################
					selected_object.attack(obj)############make attack func##############
		else:
			self.selected_object = null
			SignalManager.unit_unselected()
			
func game_object_clicked_right(obj):
	if is_turn:
		if selected_object != null and obj.get_parent() != self:
			if selected_object is Unit:
				selected_object.attack(obj)
			elif selected_object is Building:
				if selected_object.in_range(obj):###########make in range func################
					selected_object.attack(obj)############make attack func##############
		elif obj.get_parent() == self:
			print("cannot attack own unit")
			
func tilemap_clicked_left(hex):
	if is_turn:
		if selected_object != null:
			if mode == MOVE and selected_object is Unit:
				selected_object.find_path(hex)
			else:
				self.selected_object = null
				SignalManager.unit_unselected()
				
func tilemap_clicked_right(hex):
	if is_turn:
		if selected_object != null:
			if selected_object is Unit:
				selected_object.find_path(hex)

func turn_start():
	is_turn = true
	self.turn += 1
	if !is_ai:
		camera.make_current()
		$Camera2D/CanvasLayer/MainGui.turn_started(self.turn)
		$Camera2D/CanvasLayer/MainGui.visible = true
		
	if !units.empty():
		for i in self.units:
			print("unit:" + str(i))
			if i.turn_start():
				units_attention_needed.push_back(i)
			
func turn_end():
	if is_turn:
		is_turn = false
		$Camera2D/CanvasLayer/MainGui.visible = false
		$Camera2D/CanvasLayer/MainGui.turn_ended()
		SignalManager.player_turn_ended(self)

func kill(obj):
	if obj is Unit:
		units.erase(obj)
		if obj in units_attention_needed:
			units_attention_needed.erase(obj)
		if obj == selected_object:
			self.selected_object = null
			
	elif obj is Building:
		buildings.erase(obj)
