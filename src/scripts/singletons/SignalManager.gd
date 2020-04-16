extends Node

signal tech_tree_btn_click
signal end_turn_btn_click
signal unit_move_btn_click
signal unit_attack_btn_click
signal unit_build_btn_click
signal mouse_entered_gui
signal mouse_exited_gui
signal mouse_entered_game_obj(obj)
signal mouse_exited_game_obj(obj)
signal mouse_left_game_obj(obj)
signal mouse_right_game_obj(obj)
signal mouse_left_tilemap(hex)
signal mouse_right_tilemap(hex)

func tech_tree_btn_click():
	emit_signal("tech_tree_btn_click")

func end_turn_btn_click():
	emit_signal("end_turn_btn_click")
	
func unit_move_btn_click():
	emit_signal("unit_move_btn_click")
	
func unit_attack_btn_click():
	emit_signal("unit_attack_btn_click")

func unit_build_btn_click():
	emit_signal("unit_build_btn_click")
	
func mouse_entered_gui():
	emit_signal("mouse_entered_gui")
	
func mouse_exited_gui():
	emit_signal("mouse_exited_gui")
	
func mouse_entered_game_obj(obj):
	emit_signal("mouse_entered_game_obj",obj)
	
func mouse_exited_game_obj(obj):
	emit_signal("mouse_exited_game_obj",obj)

func mouse_left_game_obj(obj):
	emit_signal("mouse_left_game_obj",obj)

func mouse_right_game_obj(obj):
	emit_signal("mouse_right_game_obj",obj)
	
func mouse_left_tilemap(hex):
	emit_signal("mouse_left_tilemap",hex)
	
func mouse_right_tilemap(hex):
	emit_signal("mouse_right_tilemap",hex)
