extends Node

class_name Player

var units: Array
var buildings: Array
var is_ai: bool
var camera: PlayerCamera
var units_attention_needed: Array
var is_turn: bool
var selected_object: GameObject setget set_selected_object

var attack_flag: bool
var move_flag: bool
var build_flag: bool



func _init(start_hex,node,ai=false, debug=false):
	if debug:
		print("player init")
	node.add_child(self)
	
	self.units = Array()
	self.buildings = Array()
	
	self.selected_object = null
	
	self.is_ai = ai
	self.is_turn = false
	
	self.units += UnitFactory.start_units(start_hex,self)
	print(units)
	
	
	if !ai:
#		SignalManager.connect("end_turn_btn_click",self,"turn_end")
		SignalManager.connect("mouse_left_game_obj",self,"game_object_clicked_left")
		SignalManager.connect("mouse_right_game_obj",self,"game_object_clicked_right")
		SignalManager.connect("mouse_left_tilemap",self,"tilemap_clicked_left")
		SignalManager.connect("mouse_right_tilemap",self,"tilemap_clicked_right")
		camera = preload("res://scenes/Camera.tscn").instance()
		self.add_child(camera)
		camera.position = Hex.hex_to_point(start_hex)
		camera.zoom = Vector2(0.3,0.3)
		$Camera2D/CanvasLayer/MainGui.visible = false
		
		
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
			attack_flag = false
			move_flag = false
			build_flag = false
		elif selected_object != null and attack_flag:
			if selected_object is Unit:
				selected_object.set_target(obj)################make set target func###############
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
				selected_object.attack(obj)################make set target func###############
			elif selected_object is Building:
				if selected_object.in_range(obj):###########make in range func################
					selected_object.attack(obj)############make attack func##############
		elif obj.get_parent() == self:
			print("cannot attack own unit")
			
func tilemap_clicked_left(hex):
	if is_turn:
		if selected_object != null:
			if move_flag and selected_object is Unit:
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
	if !is_ai:
		camera.make_current()
		$Camera2D/CanvasLayer/MainGui.turn_started()
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
