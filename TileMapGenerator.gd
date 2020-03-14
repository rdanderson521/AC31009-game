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


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
						set_cell(y.pos.x,y.pos.y,7)
					elif y.height > 1.2: #rocky
						if rand_range(0,1) > 0.9 and mountains:
							set_cell(y.pos.x,y.pos.y,27)
						else:
							set_cell(y.pos.x,y.pos.y,25)
					else: #normal
						if y.humidity > 1.6: #oasis
							set_cell(y.pos.x,y.pos.y,28)
						else: #sandy
							if rand_range(0,1)>0.5:
								set_cell(y.pos.x,y.pos.y,26)
							else:
								set_cell(y.pos.x,y.pos.y,24)
								
				elif y.temp < 0: #tundra
					if y.height < -0.3 and lakes: #water
						set_cell(y.pos.x,y.pos.y,21)
					elif y.height > 1.2: #rocky
						rand = rand_range(0,1)
						if rand > 0.9 and mountains:
							set_cell(y.pos.x,y.pos.y,5)
						elif rand > 0.6:
							set_cell(y.pos.x,y.pos.y,20)
						else:
							set_cell(y.pos.x,y.pos.y,19)
					else: #snow
						set_cell(y.pos.x,y.pos.y,16)
						
				else: #grass
					if y.height < -0.3 and lakes: #water
						set_cell(y.pos.x,y.pos.y,7)
					elif y.height > 1.2: #rocky
						rand = rand_range(0,1)
						if rand > 0.9 and mountains:
							set_cell(y.pos.x,y.pos.y,5)
						elif rand > 0.6:
							set_cell(y.pos.x,y.pos.y,4)
						else:
							set_cell(y.pos.x,y.pos.y,3)
					else: #normal
						if y.humidity > 1.3: #rain forest
							set_cell(y.pos.x,y.pos.y,32)
							
						else: #grass
							if rand_range(0,1) > 0.7:
								set_cell(y.pos.x,y.pos.y,1)
							else:
								set_cell(y.pos.x,y.pos.y,0)
		

func onClear(clear):
	if clear:
		clear = false
		
		var to_clear = get_used_cells()
		
		for i in to_clear:
			set_cell(i.x,i.y,-1)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass
