extends Node

signal tech_tree_btn_click
signal end_turn_btn_click
signal start_btn_clicked
signal unit_move_btn_click(btn_down)
signal unit_attack_btn_click(btn_down)
signal unit_build_btn_click(btn_down)
signal mouse_entered_gui(gui)
signal mouse_exited_gui(gui)
signal gui_closed(gui)
signal mouse_entered_game_obj(obj)
signal mouse_exited_game_obj(obj)
signal mouse_left_game_obj(obj)
signal mouse_double_left_game_obj(obj)
signal mouse_right_game_obj(obj)
signal mouse_left_tilemap(hex)
signal mouse_right_tilemap(hex)
signal player_turn_started(player)
signal player_turn_ended(player)
signal unit_selected(unit)
signal unit_unselected
signal building_selected(building)
signal building_unselected
signal health_change(obj,h)
signal build_btn_click(building)
signal building_file_read
signal moves_left_change(unit,m)
signal unit_moved(unit,from,to)
signal move_wait_finished(unit)
signal make_unit_move(unit_to_move,unit_sender)
signal kill_unit(unit)
signal kill_building(building)
signal build_options_updated(obj)
signal select_object_btn(obj)
signal turn_start_obj_attention_needed(units,buildings)
signal building_build_start(building)
signal new_unit(unit,player)
signal new_building(building,player)
signal enable_end_turn_btn(player)

var mouse_entered: Array
var mouse_over_gui: bool
var mouse_over_gui_list: Array
var last_clicked: GameObject

func _init():
	self.mouse_entered = Array()
	self.mouse_over_gui = false
	self.mouse_over_gui_list = Array()

func tech_tree_btn_click():
	emit_signal("tech_tree_btn_click")
	#print("tech_tree_btn_click")

func end_turn_btn_click():
	emit_signal("end_turn_btn_click")
	#print("end_turn_btn_click")
	
func start_btn_clicked():
	emit_signal("start_btn_clicked")
	
func unit_move_btn_click(btn_down):
	emit_signal("unit_move_btn_click",btn_down)
	#print("unit_move_btn_click")
	
func unit_attack_btn_click(btn_down):
	emit_signal("unit_attack_btn_click",btn_down)
	#print("unit_attack_btn_click")
	
func unit_build_btn_click(btn_down):
	emit_signal("unit_build_btn_click",btn_down)
	#print("unit_build_btn_click")
	
func mouse_entered_gui(gui):
	self.mouse_over_gui_list.append(gui)
	self.mouse_over_gui = true
	emit_signal("mouse_entered_gui")
	#print("mouse_entered_gui")
	
func mouse_exited_gui(gui):
	while self.mouse_over_gui_list.has(gui):
		self.mouse_over_gui_list.erase(gui)
	if self.mouse_over_gui_list.empty():
		self.mouse_over_gui = false
	emit_signal("mouse_exited_gui")
	#print("mouse_exited_gui")
	
func gui_closed(gui):
	if gui in self.mouse_over_gui_list:
		self.mouse_over_gui_list.erase(gui)
		if self.mouse_over_gui_list.empty():
			self.mouse_over_gui = false
	emit_signal("gui_closed",gui)
	
func mouse_entered_game_obj(obj):
	mouse_entered.append(obj)
	#print("mouse_entered_game_obj")
	emit_signal("mouse_entered_game_obj",obj)
	
	
func mouse_exited_game_obj(obj):
	mouse_entered.erase(obj)
	#print("mouse_exited_game_obj")
	emit_signal("mouse_exited_game_obj",obj)
	

func mouse_left_game_obj(obj,double = false):
	if !self.mouse_over_gui:
		if double:
			emit_signal("mouse_double_left_game_obj",obj)
			#print("mouse_double_left_game_obj")
		else:
			emit_signal("mouse_left_game_obj",obj)
			#print("mouse_left_game_obj")

func mouse_right_game_obj(obj):
	if !self.mouse_over_gui:
		emit_signal("mouse_right_game_obj",obj)
	#print("mouse_right_game_obj")
	
func mouse_left_tilemap(hex):
	if self.mouse_entered.empty() and !self.mouse_over_gui:
		emit_signal("mouse_left_tilemap",hex)
		#print("mouse_left_tilemap")
	
func mouse_right_tilemap(hex):
	if self.mouse_entered.empty() and !self.mouse_over_gui:
		emit_signal("mouse_right_tilemap",hex)
		#print("mouse_right_tilemap")
		
func player_turn_started(player):
	emit_signal("player_turn_started",player)
	#print("player_turn_started")
		
func player_turn_ended(player):
	emit_signal("player_turn_ended",player)
	#print("player_turn_ended")
	
func unit_selected(unit):
	emit_signal("unit_selected",unit)
	#print("unit_selected")
	
func unit_unselected():
	emit_signal("unit_unselected")
	#print("unit_unselected")
	
func building_selected(building):
	emit_signal("building_selected",building)
	print("building_selected")
	
func building_unselected():
	emit_signal("building_unselected")
	#print("unit_unselected")
	
func health_change(obj,h):
	emit_signal("health_change",obj,h)
	
func build_btn_click(building):
	emit_signal("build_btn_click",building)

func building_file_read():
	emit_signal("building_file_read")
	#print("building file read")
	
func moves_left_change(unit,m):
	emit_signal("moves_left_change",unit,m)
	#print("moves left change")
	
func unit_moved(unit,from,to):
	emit_signal("unit_moved",unit,from,to)
	
func move_wait_finished(unit):
	emit_signal("move_wait_finished",unit)
	
func make_unit_move(unit_to_move,unit_sender):
	emit_signal("make_unit_move",unit_to_move,unit_sender)
	
func kill_unit(unit):
	if unit in self.mouse_entered:
		self.mouse_entered.erase(unit)
	emit_signal("kill_unit",unit)
	
func kill_building(building):
	if building in self.mouse_entered:
		self.mouse_entered.erase(building)
	emit_signal("kill_building",building)
	
func build_options_updated(obj):
	emit_signal("build_options_updated",obj)
	
func select_object_btn(obj):
	emit_signal("select_object_btn",obj)
	
func turn_start_obj_attention_needed(units,buildings):
	emit_signal("turn_start_obj_attention_needed",units,buildings)
	
func building_build_start(building):
	emit_signal("building_build_start",building)
	
func new_unit(unit,player):
	emit_signal("new_unit",unit,player)
	
func new_building(building,player):
	emit_signal("new_building",building,player)
	
func enable_end_turn_btn(player):
	emit_signal("enable_end_turn_btn",player)

	
	
