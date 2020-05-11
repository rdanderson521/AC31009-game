extends Player
class_name Human

var camera: PlayerCamera
var fow_canvas: Node2D

var mode: int

const DEFAULT = 0
const MOVE = 1
const ATTACK = 3
const BUILD = 5

func _init(start_hex:Vector2).(start_hex,false):
	SignalManager.connect("end_turn_btn_click",self,"turn_end")
	SignalManager.connect("mouse_left_game_obj",self,"game_object_clicked_left")
	SignalManager.connect("mouse_double_left_game_obj",self,"game_object_double_clicked_left")
	SignalManager.connect("mouse_right_game_obj",self,"game_object_clicked_right")
	SignalManager.connect("mouse_left_tilemap",self,"tilemap_clicked_left")
	SignalManager.connect("mouse_right_tilemap",self,"tilemap_clicked_right")
	SignalManager.connect("build_btn_click",self,"start_build")
	SignalManager.connect("unit_moved",self,"unit_moved")
	SignalManager.connect("move_wait_finished",self,"unit_turn_finished")
	
	self.unit_vis_range = 2
	self.building_vis_range = 3
	
	self.camera = preload("res://scenes/Camera.tscn").instance()
	camera.position = Hex.hex_to_point(start_hex)
	camera.zoom = Vector2(0.3,0.3)
	self.add_child(self.camera)
	$Camera2D/CanvasLayer/MainGui.visible = false
	
	fow_canvas = preload("res://scripts/DrawFogOfWar.gd").new()###############
	fow_canvas.visible = false
	self.add_child(fow_canvas)

func _ready():
	self.fow = GlobalConfig.map.keys().duplicate()
	var start_area_hex = Hex.hex_in_range(4,self.start_hex)
	for i in start_area_hex:
		fow.erase(i)
		not_fow.append(i)
	fow_canvas.draw_fow(fow)
	
func game_object_clicked_left(obj:GameObject):
	if is_turn:
		if obj.get_parent() == self:
			if obj is Building:
				print("obj is building")
				if !obj.hex_pos in GlobalConfig.unit_tiles.keys():
					self.selected_object = obj
					self.mode = 0
			elif obj is Unit:
				print("obj is unit")
				self.selected_object = obj
				self.mode = DEFAULT
				
		elif selected_object != null and mode == ATTACK:
			if selected_object is Unit:
				selected_object.attack(obj)
			elif selected_object is Building:
				if selected_object.in_range(obj):###########make in range func################
					selected_object.attack(obj)############make attack func##############
		else:
			self.selected_object = null
			SignalManager.unit_unselected()
			SignalManager.building_unselected()
			
func game_object_double_clicked_left(obj:GameObject):
	if is_turn:
		if obj.get_parent() == self and obj is Building:
			self.selected_object = obj
			self.mode = DEFAULT
			
func game_object_clicked_right(obj:GameObject):
	if is_turn:
		if selected_object != null and obj.get_parent() != self:
			if selected_object is Unit:
				selected_object.attack(obj)
			elif selected_object is Building:
				if selected_object.in_range(obj):###########make in range func################
					selected_object.attack(obj)############make attack func##############
		elif obj.get_parent() == self and obj is Unit:
			print("cannot attack own unit")
		elif obj.get_parent() == self and obj is Building and !(obj.hex_pos in GlobalConfig.unit_tiles.keys()):
			if selected_object is Unit:
				selected_object.find_path(obj.hex_pos)
			
			
func tilemap_clicked_left(hex:Vector2):
	if is_turn:
		if selected_object != null:
			if mode == MOVE and self.selected_object is Unit:
				self.selected_object.find_path(hex)
			else:
				self.selected_object = null
				
func tilemap_clicked_right(hex:Vector2):
	if is_turn:
		if selected_object != null:
			if selected_object is Unit:
				selected_object.find_path(hex)
				
				
func turn_start():
	print("turn start")
	self.is_turn = true
	self.turn += 1
	self.fow_canvas.draw()
	
	camera.make_current()
	$Camera2D/CanvasLayer/MainGui.turn_started(self.turn)
	if !units.empty():
		for i in self.units:
			if i.turn_start():
				units_attention_needed.push_back(i)
	if !buildings.empty():
		for i in self.buildings:
			if i.turn_start():
				buildings_attention_needed.push_back(i)
			
func turn_end():
	var all_units_done = true
	if is_turn:
		is_turn = false
		selected_object = null
		units_attention_needed.clear()
		$Camera2D/CanvasLayer/MainGui.turn_ended()
	if !is_turn:
		
		for i in units:
			if !i.turn_end():
				units_attention_needed.append(i)

		if units_attention_needed.empty():
			#self.fow_canvas.visible = false
			#$Camera2D/CanvasLayer/MainGui.visible = false
			SignalManager.player_turn_ended(self)
		else: 
			print("error ending turn")
			
func unit_turn_finished(unit):
	if unit in self.units_attention_needed and !self.is_turn:
		self.units_attention_needed.erase(unit)
		self.turn_end()
		
func start_build(to_build:String):
	if is_turn:
		if selected_object is Unit:
			if selected_object.can_build(to_build):
				selected_object.start_build(to_build)
		elif selected_object is Building:
			if selected_object.can_build(to_build):
				selected_object.start_build(to_build)
				
func reset_visible():
	visible_tiles = Array()
	for i in self.units:
		var hex_area = Hex.hex_in_range(self.unit_vis_range,i.hex_pos)
		visible_tiles += hex_area
		for j in hex_area:
			if fow.has(j):
				fow.erase(j)
				not_fow.append(j)
	for i in self.buildings:
		var hex_area = Hex.hex_in_range(self.building_vis_range,i.hex_pos)
		visible_tiles += hex_area
		for j in hex_area:
			if fow.has(j):
				fow.erase(j)
				not_fow.append(j)
	self.fow_canvas.fog_of_war = self.fow
	self.fow_canvas.visible_tiles = self.visible_tiles
	self.fow_canvas.draw()
		
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
	self.fow_canvas.fog_of_war = self.fow
	self.fow_canvas.visible_tiles = self.visible_tiles
	self.fow_canvas.draw()
