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
	$TileMap.generate(true)
	init_players(1)
	

func init_players(num_players):
	for i in range(num_players):
		var x
		var y
		var start_hex = Vector2()
		var valid_start_pos = false
		var j = 0
		while !valid_start_pos and j < 10:
			j += 1
			x = int(rand_range(2,15))#GlobalConfig.map_size.x-3))
			y = int(rand_range(2,15))#GlobalConfig.map_size.y-3))
			y -= abs(x/2)
			start_hex = Vector2(x,y)
			if not GlobalConfig.map[start_hex] in GlobalConfig.impasible_biomes and not GlobalConfig.map[start_hex] in GlobalConfig.water_biomes:
				var start_area = Hex.hex_in_range(2,start_hex)
				var invalid_start = false
				for k in start_area:
					print(GlobalConfig.map[k])
					if GlobalConfig.map[k] in GlobalConfig.impasible_biomes or GlobalConfig.map[k] in GlobalConfig.water_biomes:
						invalid_start = true
				if !invalid_start:
					valid_start_pos = true
		if valid_start_pos:
			var player = Player.new(start_hex,self)
			player.set_name("Player"+str(i))
			self.add_child(player)
	
