extends Node2D

class_name main

var players: Array
var curr_player: Player
var curr_camera: Camera2D

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		var global_click_position =  (curr_camera.get_camera_position() + (( event.position - curr_camera.get_viewport().get_visible_rect().size/2) * curr_camera.scale * curr_camera.get_zoom()))
		var hex_coord = Hex.point_to_hex(global_click_position)
#		print("global click: " + str(global_click_position))
#		print("hex click: " + str(hex_coord))
		if event.button_index == BUTTON_LEFT:
			SignalManager.mouse_left_tilemap(hex_coord)
		elif event.button_index == BUTTON_RIGHT:
			SignalManager.mouse_right_tilemap(hex_coord)
			
func _init():
	SignalManager.connect("player_turn_ended",self,"next_player")
	SignalManager.connect("end_turn_btn_click",self,"end_turn_btn_click")
	
func end_turn_btn_click():
	curr_player.turn_end()

func next_player(player):
	var player_idx = players.find(player)
	
	print("player:" + str(player_idx))
	print("size: " + str(players.size()))
	
	if player_idx+1 == players.size():
		curr_player = players[0]
	else:
		curr_player = players[player_idx+1]
	curr_player.turn_start()
	if !curr_player.is_ai:
		curr_camera = curr_player.camera

func _ready():
	randomize()
	$TileMap.generate(true)
	init_players(2)
	curr_player = players.front()
	curr_player.turn_start()
	curr_camera = curr_player.camera
	
	
func init_players(num_players):
	players = Array()
	for i in range(num_players):
		var x
		var y
		var start_hex = Vector2()
		var valid_start_pos = false
		var j = 0
		while !valid_start_pos and j < 10:
			j += 1
			x = int(rand_range(2,GlobalConfig.map_size.x-3))
			y = int(rand_range(2,GlobalConfig.map_size.y-3))
			y -= abs(x/2)
			start_hex = Vector2(x,y)
			if not GlobalConfig.map[start_hex] in GlobalConfig.impasible_biomes and not GlobalConfig.map[start_hex] in GlobalConfig.water_biomes:
				var start_area = Hex.hex_in_range(2,start_hex)
				var invalid_start = false
				for k in start_area:
					#print(GlobalConfig.map[k])
					if GlobalConfig.map[k] in GlobalConfig.impasible_biomes or GlobalConfig.map[k] in GlobalConfig.water_biomes:
						invalid_start = true
				if !invalid_start:
					valid_start_pos = true
		if valid_start_pos:
			var player = Player.new(start_hex,self)
			player.set_name("Player"+str(i))
			players.push_back(player)
			self.add_child(player)
	print("num players: " + str(players.size()))
