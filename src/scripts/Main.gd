extends Node2D

class_name main

var players: Array

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var camera = $Camera2D
		var global_click_position =  (camera.get_camera_position() + (( event.position - camera.get_viewport().get_visible_rect().size/2) * camera.scale * camera.get_zoom()))
		var hex_coord = Hex.point_to_hex(global_click_position)
		print("global click: " + str(global_click_position))
		print("hex click: " + str(hex_coord))
		if event.button_index == BUTTON_LEFT:
			SignalManager.mouse_left_tilemap(hex_coord)
		elif event.button_index == BUTTON_RIGHT:
			SignalManager.mouse_right_tilemap(hex_coord)

func _ready():
	randomize()
	init_players(1)

func init_players(num_players):
	for i in range(num_players):
		var x = int(rand_range(1,10))
		var y = int(rand_range(10,20))
		y -= abs(x/2)
		var start_hex = Vector2(x,y)
		var player = Player.new(start_hex,self)
		player.set_name("Player"+str(i))
		self.add_child(player)
		print(get_tree())
