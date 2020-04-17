extends Node

signal tech_tree_btn_click
signal end_turn_btn_click
signal unit_move_btn_click(btn_down)
signal unit_attack_btn_click(btn_down)
signal unit_build_btn_click(btn_down)
signal mouse_entered_gui
signal mouse_exited_gui
signal mouse_entered_game_obj(obj)
signal mouse_exited_game_obj(obj)
signal mouse_left_game_obj(obj)
signal mouse_right_game_obj(obj)
signal mouse_left_tilemap(hex)
signal mouse_right_tilemap(hex)
signal player_turn_ended(player)
signal unit_selected(unit)
signal unit_unselected

var mouse_entered: Array
var mouse_over_gui: bool

func _init():
	self.mouse_entered = Array()
	self.mouse_over_gui = false

func tech_tree_btn_click():
	emit_signal("tech_tree_btn_click")
	print("tech_tree_btn_click")

func end_turn_btn_click():
	emit_signal("end_turn_btn_click")
	print("end_turn_btn_click")
	
func unit_move_btn_click(btn_down):
	emit_signal("unit_move_btn_click",btn_down)
	print("unit_move_btn_click")
	
func unit_attack_btn_click(btn_down):
	emit_signal("unit_attack_btn_click",btn_down)
	print("unit_attack_btn_click")
	
func unit_build_btn_click(btn_down):
	emit_signal("unit_build_btn_click",btn_down)
	print("unit_build_btn_click")
	
func mouse_entered_gui():
	self.mouse_over_gui = true
	emit_signal("mouse_entered_gui")
	print("mouse_entered_gui")
	
func mouse_exited_gui():
	self.mouse_over_gui = false
	emit_signal("mouse_exited_gui")
	print("mouse_exited_gui")
	
func mouse_entered_game_obj(obj):
	mouse_entered.append(obj)
	emit_signal("mouse_entered_game_obj",obj)
	print("mouse_entered_game_obj")
	
func mouse_exited_game_obj(obj):
	mouse_entered.erase(obj)
	emit_signal("mouse_exited_game_obj",obj)
	print("mouse_exited_game_obj")

func mouse_left_game_obj(obj):
	emit_signal("mouse_left_game_obj",obj)
	print("mouse_left_game_obj")

func mouse_right_game_obj(obj):
	emit_signal("mouse_right_game_obj",obj)
	print("mouse_right_game_obj")
	
func mouse_left_tilemap(hex):
	if self.mouse_entered.empty():
		emit_signal("mouse_left_tilemap",hex)
		print("mouse_left_tilemap")
	
func mouse_right_tilemap(hex):
	if self.mouse_entered.empty():
		emit_signal("mouse_right_tilemap",hex)
		print("mouse_right_tilemap")
		
func player_turn_ended(player):
	emit_signal("player_turn_ended",player)
	print("player_turn_ended")
	
func unit_selected(unit):
	emit_signal("unit_selected",unit)
	print("unit_selected")
	
func unit_unselected():
	emit_signal("unit_unselected")
	print("unit_unselected")
