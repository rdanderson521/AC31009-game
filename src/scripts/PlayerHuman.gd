extends Player
class_name Human

var camera: PlayerCamera
var fow_canvas: Node2D

var mode: int

enum {DEFAULT,MOVE,ATTACK,BUILD}

func _init(start_hex:Vector2).(start_hex):
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
	self.camera.position = Hex.hex_to_point(start_hex)
	self.camera.zoom = Vector2(0.3,0.3)
	self.add_child(self.camera)
	$Camera2D/CanvasLayer/MainGui.visible = false
	
	self.fow_canvas = preload("res://scripts/DrawFogOfWar.gd").new()###############
	self.fow_canvas.visible = false
	self.add_child(fow_canvas)

func _ready():
	self.fow_canvas.draw_fow(fow)
	
func game_object_clicked_left(obj:GameObject):
	if self.is_turn:
		if obj.get_parent() == self:
			if obj is Building:
				if !obj.hex_pos in GlobalConfig.unit_tiles.keys():
					self.selected_object = obj
					self.mode = DEFAULT
			elif obj is Unit:
				self.selected_object = obj
				self.mode = DEFAULT
				
		elif self.selected_object != null and self.mode == ATTACK:
			if self.selected_object is Unit:
				self.selected_object.attack(obj)
			elif self.selected_object is Building:
				if self.selected_object.in_range(obj):###########make in range func################
					self.selected_object.attack(obj)############make attack func##############
		else:
			self.selected_object = null
			SignalManager.unit_unselected()
			SignalManager.building_unselected()
			
func game_object_double_clicked_left(obj:GameObject):
	if self.is_turn:
		if obj.get_parent() == self and obj is Building:
			self.selected_object = obj
			self.mode = DEFAULT
			
func game_object_clicked_right(obj:GameObject):
	if self.is_turn:
		if self.selected_object != null and obj.get_parent() != self:
			if self.selected_object is Unit:
				self.selected_object.attack(obj)
			elif self.selected_object is Building:
				if self.selected_object.in_range(obj):###########make in range func################
					self.selected_object.attack(obj)############make attack func##############
		elif obj.get_parent() == self and obj is Unit:
			pass
			################################################### attacking own unit not allowed
		elif obj.get_parent() == self and obj is Building and !(obj.hex_pos in GlobalConfig.unit_tiles.keys()):
			if self.selected_object is Unit:
				self.selected_object.find_path(obj.hex_pos)
			
			
func tilemap_clicked_left(hex:Vector2):
	if self.is_turn:
		if self.selected_object != null:
			if self.mode == MOVE and self.selected_object is Unit:
				self.selected_object.find_path(hex)
			else:
				self.selected_object = null
				
func tilemap_clicked_right(hex:Vector2):
	if self.is_turn:
		if self.selected_object != null:
			if self.selected_object is Unit:
				self.selected_object.find_path(hex)
				
				
func turn_start():
	self.is_turn = true
	self.turn += 1
	self.fow_canvas.draw()
	
	self.camera.make_current()
	$Camera2D/CanvasLayer/MainGui.turn_started(self.turn)
	if !self.units.empty():
		for i in self.units:
			if i.turn_start():
				self.units_attention_needed.push_back(i)
	if !self.buildings.empty():
		for i in self.buildings:
			if i.turn_start():
				self.buildings_attention_needed.push_back(i)
			
func turn_end():
	var all_units_done = true
	if self.is_turn:
		self.is_turn = false
		self.selected_object = null
		self.units_attention_needed.clear()
		$Camera2D/CanvasLayer/MainGui.turn_ended()
	if !self.is_turn:
		
		for i in self.units:
			if !i.turn_end():
				self.units_attention_needed.append(i)

		if self.units_attention_needed.empty():
			SignalManager.player_turn_ended(self)
		else: 
			print("error ending turn")
			
func unit_turn_finished(unit:Unit):
	if unit in self.units_attention_needed and !self.is_turn:
		self.units_attention_needed.erase(unit)
		self.turn_end()
		
func start_build(to_build:String):
	if self.is_turn:
		if self.selected_object is Unit:
			if self.selected_object.can_build(to_build):
				self.selected_object.start_build(to_build)
		elif self.selected_object is Building:
			if self.selected_object.can_build(to_build):
				self.selected_object.start_build(to_build)
				
func reset_visible():
	self.visible_tiles = Array()
	for i in self.units:
		var hex_area = Hex.hex_in_range(self.unit_vis_range,i.hex_pos)
		self.visible_tiles += hex_area
		for j in hex_area:
			if self.fow.has(j):
				self.fow.erase(j)
				self.not_fow.append(j)
	for i in self.buildings:
		var hex_area = Hex.hex_in_range(self.building_vis_range,i.hex_pos)
		self.visible_tiles += hex_area
		for j in hex_area:
			if self.fow.has(j):
				self.fow.erase(j)
				self.not_fow.append(j)
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
