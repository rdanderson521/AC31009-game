tool extends TileMapBase

var lakes: bool = true
var mountains: bool = true
var blob_num: int = 700
var blob_size: int = 50
var blob_effect: float = 0.9
var blob_detirioration: int = 15
var grid_x: int = 50
var grid_y: int = 35
var debug: bool = false

var map: Array
var tiles = GlobalConfig.biomes 
	
# Called when the node enters the scene tree for the first time.
func _init().():
		self.position = Vector2(-16,-32)
	

class HexNode:
	var pos
	var height
	var temp
	var humidity
	var biome
	var power 
	
	func _init(pos):
		self.pos = pos
		self.height = 0.5
		self.temp = 0.5
		self.humidity = 0.5
		self.biome = 0

func generate():

	map = Array()
	
	for y in range(-GlobalConfig.map_border,grid_y+GlobalConfig.map_border):
		for x in range(-GlobalConfig.map_border,grid_x+GlobalConfig.map_border):
			if x < 0 or x > grid_x-1 or y < 0 or y > grid_y-1:
				if x >= 0:
					set_cell(x,y-int(x/2),tiles["mountain"])
				else:
					set_cell(x,y-int((x-1)/2),tiles["mountain"])
	
	for y in range(grid_y):
		for x in range(grid_x):
			var offset = int(x/2)
			map.push_back((HexNode.new(Vector2(x,y-offset))))
	
	for _i in range(blob_num):
		var rand_x = int(rand_range(0,grid_x))
		var rand_y = int(rand_range(0,grid_y))
		var start_cell = map[rand_y*grid_x + rand_x]
		start_cell.power = blob_size
		
		var blob_temp = rand_range(blob_effect/2,blob_effect)
		if rand_range(0,1) > 0.5:
			blob_temp = -blob_temp
			
		var blob_height = rand_range(blob_effect/2,blob_effect)
		if rand_range(0,1) > 0.5:
			blob_height = -blob_height
			
		var blob_humidity = rand_range(blob_effect/2,blob_effect)
		if rand_range(0,1) > 0.5:
			blob_humidity = -blob_humidity
		
		var blob_cells = Array()
		var blob_visited = Dictionary()
		
		blob_cells.push_back(start_cell)
		
		var idx = 10000
		while !blob_cells.empty() and idx > 0:
			idx = idx - 1
			blob_cells.shuffle()
			var curr_blob = blob_cells.pop_front()
			while blob_visited.has(Vector2(curr_blob.pos.x,curr_blob.pos.y)) and !blob_cells.empty():
				curr_blob = blob_cells.pop_front()
			
			
			if blob_visited.has(Vector2(curr_blob.pos.x,curr_blob.pos.y)):
				break 
				
			if curr_blob.power > 0:
				
				curr_blob.height += blob_height*(curr_blob.power/blob_size)
				curr_blob.temp += blob_temp*(curr_blob.power/blob_size)
				curr_blob.humidity += blob_humidity*(curr_blob.power/blob_size)
				
				blob_visited[curr_blob.pos] = curr_blob
				
				var arr_x = curr_blob.pos.x
				var arr_y = curr_blob.pos.y+(int(arr_x/2))
				
				var new_cells = Hex_ops.hex_in_range(1,curr_blob.pos)
				for j in new_cells:
					var pos_diff = j - curr_blob.pos
					
					if j.y+int(j.x/2) >= grid_y or j.y+int(j.x/2) < 0:
						break
					
					if j.x < 0:
						var old_x = j.x
						var old_y = j.y
						j.x = grid_x-1
						j.y = old_y - int((j.x-old_x)/2)
						
					if j.x >= grid_x:
						var old_x = j.x
						var old_y = j.y
						j.x = 0
						j.y = old_y - int((j.x-old_x)/2)
						
					blob_cells.push_back(map[(j.y+(int(j.x/2)))*grid_x+j.x])
					blob_cells.back().power = curr_blob.power - rand_range(1,blob_detirioration)
			
	for y in map:
		if debug:
			print (str(y.pos.x) + "," + str(y.pos.y) + ": " + str(y.height))
		
		var rand
		if y.temp > 1: #desert
			if y.height < -0.5 and lakes: #water
				set_cell(y.pos.x,y.pos.y,tiles["water"])
			elif y.height > 1.2: #rocky
				if rand_range(0,1) > 0.9 and mountains:
					set_cell(y.pos.x,y.pos.y,tiles["desert_mountain"])
				else:
					set_cell(y.pos.x,y.pos.y,tiles["desert_rocks"])
			else: #normal
				if y.humidity > 1.6: #oasis
					set_cell(y.pos.x,y.pos.y,tiles["desert_oasis"])
				else: #sandy
					if rand_range(0,1)>0.5:
						set_cell(y.pos.x,y.pos.y,tiles["desert"])
					else:
						set_cell(y.pos.x,y.pos.y,tiles["desert_dunes"])
						
		elif y.temp < 0: #tundra
			if y.height < -0.3 and lakes: #water
				set_cell(y.pos.x,y.pos.y,tiles["water_ice"])
			elif y.height > 1.2: #rocky
				rand = rand_range(0,1)
				if rand > 0.9 and mountains:
					set_cell(y.pos.x,y.pos.y,tiles["mountain"])
				elif rand > 0.6:
					set_cell(y.pos.x,y.pos.y,tiles["snow_rocks_trees"])
				else:
					set_cell(y.pos.x,y.pos.y,tiles["snow_rocks"])
			else: #snow
				if rand_range(0,1) > 0.7:
					set_cell(y.pos.x,y.pos.y,tiles["snow_trees"])
				else:
					set_cell(y.pos.x,y.pos.y,tiles["snow"])
				
		else: #grass
			if y.height < -0.3 and lakes: #water
				set_cell(y.pos.x,y.pos.y,tiles["water"])
			elif y.height > 1.2: #rocky
				rand = rand_range(0,1)
				if rand > 0.9 and mountains:
					set_cell(y.pos.x,y.pos.y,tiles["mountain"])
				elif rand > 0.6:
					set_cell(y.pos.x,y.pos.y,tiles["grass_rocks_trees"])
				else:
						set_cell(y.pos.x,y.pos.y,tiles["grass_rocks"])
			else: #normal
				if y.humidity > 1.3: #rain forest
					set_cell(y.pos.x,y.pos.y,tiles["rainforest"])
					
				else: #grass
					if rand_range(0,1) > 0.7:
						set_cell(y.pos.x,y.pos.y,tiles["grass_trees"])
					else:
						set_cell(y.pos.x,y.pos.y,tiles["grass"])
		
		y.biome = get_cell(y.pos.x,y.pos.y)
		GlobalConfig.map[Vector2(y.pos.x,y.pos.y)] = y.biome
		GlobalConfig.map_size = Vector2(grid_x,grid_y)
			
func clear():
	for i in self.get_used_cells():
		set_cellv(i,-1)
	
