extends "res://scripts/Player.gd"

class_name Human

func _init(start_hex:Vector2).(start_hex,false):
	SignalManager.connect("end_turn_btn_click",self,"turn_end")
	SignalManager.connect("mouse_left_game_obj",self,"game_object_clicked_left")
	SignalManager.connect("mouse_double_left_game_obj",self,"game_object_double_clicked_left")
	SignalManager.connect("mouse_right_game_obj",self,"game_object_clicked_right")
	SignalManager.connect("mouse_left_tilemap",self,"tilemap_clicked_left")
	SignalManager.connect("mouse_right_tilemap",self,"tilemap_clicked_right")
	SignalManager.connect("build_btn_click",self,"unit_start_build")
	SignalManager.connect("unit_moved",self,"unit_moved")
	self.camera = preload("res://scenes/Camera.tscn").instance()
	self.add_child(self.camera)
	camera.position = Hex.hex_to_point(start_hex)
	camera.zoom = Vector2(0.3,0.3)
	$Camera2D/CanvasLayer/MainGui.visible = false
	
	fow_canvas = preload("res://scripts/DrawFogOfWar.gd").new()###############
	fow_canvas.visible = false
	self.add_child(fow_canvas)


func game_object_clicked_left(obj:GameObject):
	if is_turn:
		if obj.get_parent() == self:
			if obj is Building:
				print("obj is building")
				if !obj.hex_pos in GlobalConfig.unit_tiles.keys():
					self.selected_object = obj
					self.mode = 0
			else:
				print("obj is unit")
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
			SignalManager.building_unselected()
			
func game_object_double_clicked_left(obj:GameObject):
	if is_turn:
		if obj.get_parent() == self and obj is Building:
			self.selected_object = obj
			self.mode = 0
			
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
			if mode == MOVE and selected_object is Unit:
				selected_object.find_path(hex)
			else:
				self.selected_object = null
				SignalManager.unit_unselected()
				SignalManager.building_unselected()
				
func tilemap_clicked_right(hex:Vector2):
	if is_turn:
		if selected_object != null:
			if selected_object is Unit:
				selected_object.find_path(hex)
				
				
func turn_start():
	is_turn = true
	self.turn += 1
	camera.make_current()
	self.fow_canvas.visible = true
	self.fow_canvas.draw()
	$Camera2D/CanvasLayer/MainGui.turn_started(self.turn)
		
	if !units.empty():
		for i in self.units:
			#print("unit:" + str(i))
			if i.turn_start():
				units_attention_needed.push_back(i)
			
func turn_end():
	if is_turn:
		is_turn = false
		selected_object = null
		$Camera2D/CanvasLayer/MainGui.visible= false
		$Camera2D/CanvasLayer/MainGui.turn_ended()
		SignalManager.player_turn_ended(self)
		self.fow_canvas.visible = false
		
		
func unit_moved(unit:Unit,from:Vector2,to:Vector2):
	print("testtest1")
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
