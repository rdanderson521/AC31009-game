extends Node2D


func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var camera = $Camera2D
		var global_click_position =  (camera.get_camera_position() + (( event.position - camera.get_viewport().get_visible_rect().size/2) * camera.scale * camera.get_zoom()))
		var hex_coord = Hex.point_to_hex(global_click_position)
		if event.button_index == BUTTON_LEFT:
			SignalManager.mouse_left_tilemap(hex_coord)
		elif event.button_index == BUTTON_RIGHT:
			SignalManager.mouse_right_tilemap(hex_coord)
