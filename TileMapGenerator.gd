tool extends TileMap

export(bool) var lakes = false
export(bool) var mountains = false
export(int) var blob_num = 70
export(int) var blob_size = 100
export(float) var blob_effect = 1
export(int) var grid_x = 100
export(int) var grid_y = 60
export(bool) var generate = false setget onGenerate
export(bool) var clear = false setget onClear

var map = Array()
var tiles = {"grass":0,"grass_trees":1,"grass_forest":2,"grass_rocks":3,"grass_rocks_trees":4,"mountain":5,
	"rainforest":6,"snow":7,"snow_trees":8,"snow_forest":9,"snow_rocks":10,"snow_rocks_trees":11,
	"water_ice":12,"water":13,"desert":14,"desert_rocks":15,"desert_dunes":16,"desert_mountain":17,
	"desert_oasis":18,"fog":19,"fog_transparent":20}


# Called when the node enters the scene tree for the first time.
func _ready():
	self.cell_custom_transform.y.y = sqrt(3)*(self.cell_size.x/2)
	self.cell_custom_transform.x.y = (sqrt(3)*(self.cell_size.x/2))/2
	self.cell_size.y = sqrt(3)*(self.cell_size.x/2)



class Hex:
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

func onGenerate(generate):
	if generate:
		generate = false
		
		map = Array()
		
		for y in range(grid_y):
			for x in range(grid_x):
				var offset = int(x/2)
				map.push_back((Hex.new(Vector2(x,y-offset))))
		
		for _i in range(blob_num):
			var rand_x = int(rand_range(0,grid_x))
			var rand_y = int(rand_range(0,grid_y))
			var start_cell = map[rand_y*grid_x + rand_x]
			start_cell.power = blob_size
			var blob_temp = rand_range(-blob_effect,blob_effect)
			var blob_height = rand_range(-blob_effect,blob_effect)
			var blob_humidity = rand_range(-blob_effect,blob_effect)
			
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
					
					var x = curr_blob.pos.x
					var y = curr_blob.pos.y+(int(x/2))
					if y-1 >= 0: #y-1 x
						blob_cells.push_back(map[(y-1)*grid_x+x])
						blob_cells.back().power = curr_blob.power - rand_range(1,5)
						
					if y-1 >= 0: #y-1 x+1
						if x+1 < grid_x:
							blob_cells.push_back(map[(y-1)*grid_x+x+1])
						else:
							blob_cells.push_back(map[(y-1)*grid_x+0])
						blob_cells.back().power = curr_blob.power - rand_range(1,5)
						
					if x+1 < grid_x: #y x+1
						blob_cells.push_back(map[y*grid_x+x+1])
					else:
						blob_cells.push_back(map[y*grid_x+0])
					blob_cells.back().power = curr_blob.power - rand_range(1,5)
						
					if y+1 < grid_y: #y+1 x
						blob_cells.push_back(map[(y+1)*grid_x+x])
						blob_cells.back().power = curr_blob.power - rand_range(1,5)
						
					if y < grid_y-1:
						if x-1 >= 0: #y+1 x-1
							blob_cells.push_back(map[(y+1)*grid_x+x-1])
						else:
							blob_cells.push_back(map[(y+1)*grid_x+grid_x-1])
						blob_cells.back().power = curr_blob.power - rand_range(1,5)
					
					if x-1 >= 0: #y x-1
						blob_cells.push_back(map[y*grid_x+x-1])
					else:
						blob_cells.push_back(map[y*grid_x+grid_x-1])
					blob_cells.back().power = curr_blob.power - rand_range(1,5)
				
		for y in map:
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
		

func onClear(clear):
	if clear:
		clear = false
		
		var to_clear = get_used_cells()
		
		for i in to_clear:
			set_cell(i.x,i.y,-1)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
