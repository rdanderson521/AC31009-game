extends Node2D

class_name Main

var players: Array
var curr_player: Player
var curr_camera: Camera2D
var game_turn: int
var game_started: bool

func _input(event):
	if self.game_started:
		if event is InputEventMouseButton and event.is_pressed():
			var global_click_position =  (curr_camera.get_camera_position() + 
				(( event.position - curr_camera.get_viewport().get_visible_rect().size/2) * curr_camera.scale * curr_camera.get_zoom()))
			var hex_coord = Hex.point_to_hex(global_click_position)
			if event.button_index == BUTTON_LEFT:
				SignalManager.mouse_left_tilemap(hex_coord)
			elif event.button_index == BUTTON_RIGHT:
				SignalManager.mouse_right_tilemap(hex_coord)
			
func _init():
	SignalManager.connect("player_turn_ended",self,"next_player")
	SignalManager.connect("start_btn_clicked",self,"start_game")
	self.game_started = false
	self.game_turn = 0
	

func next_player(player):
	#print ("next turn")
	var player_idx = players.find(player)
	if player_idx+1 == players.size():
		curr_player = players[0]
	else:
		curr_player = players[player_idx+1]
	curr_player.turn_start()
	if curr_player is Human:
		curr_camera = curr_player.camera

func _ready():
	randomize()
	$TileMap.clear()
	
func start_game():
	
	var map_made = false
	var player_start_areas
	var idx = 0
	while !map_made and idx < 3:
		idx += 1
		$TileMap.generate(true)
		$TileMap/TileMap.generate()
		player_start_areas = init_player_start_areas(4)
		if typeof(player_start_areas) == TYPE_ARRAY:
			map_made = true
	if map_made:
		self.find_node("StartGui").visible = false
		init_players(4, player_start_areas)
		curr_player = players.front()
		curr_player.turn_start()
		curr_camera = curr_player.camera
		self.game_turn = 0
		self.game_started = true
	
func init_player_start_areas(num_players):
	var start_areas = Array()
	var intersection_check_array = Array()
	
	var x_itterations = int((GlobalConfig.map_size.x-10)/10)
	var y_itterations = int((GlobalConfig.map_size.y-10)/10)
	
	var start_areas_found = 0
	
	for i in range(0,y_itterations):
		for j in range(0,x_itterations):
			var found = false
			var idx = 0
			while !found and idx < 3:
				idx += 1
				var x = int(rand_range(5+(j*10), 5+((j+1)*10)))
				var y = int(rand_range(5+(i*10), 5+((i+1)*10))) - int(x/2)
				
				var start_hex = Vector2(x,y)
				
				var start_area = Hex.hex_in_range(2,start_hex)
				var no_enemy_area = Hex.hex_in_range(5,start_hex)
				var valid_start = true
				
				for k in no_enemy_area:
					if k in start_area:
						if GlobalConfig.map[k] in GlobalConfig.impasible_biomes or GlobalConfig.map[k] in GlobalConfig.water_biomes:
							valid_start = false
							break
					if k in intersection_check_array:
						valid_start = false
						break
					
				if valid_start:
					start_areas.append(start_hex)
					intersection_check_array += no_enemy_area
					found = true
					start_areas_found += 1
	if start_areas_found < num_players:
		return false
	else:
		return start_areas
				
	
func init_players(num_players,start_areas):
	self.players = Array()
	for i in range(num_players):
		start_areas.shuffle()
		var player
		if i < 1:
			player = Human.new(start_areas.pop_back())
		else:
			player = AI.new(start_areas.pop_back())
		player.colour = Color(1,0,0,0.3)
		player.set_name("Player"+str(i))
		self.players.push_back(player)
		add_child(player)
		
