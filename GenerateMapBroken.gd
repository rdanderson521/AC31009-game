tool
extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(bool) var generate = false setget onGenerate

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#1 11 14 13 16
var map_x = 50
var map_y = 30
var default_tile = 0;
var num_biomes = 70;
var biomes = [0,14,16,24,15]
var starting_power = 150
var tiles = {0:3,1:0.2,2:0.05,3:0.05,4:0.05,5:0.05,7:0.3,16:2.5}

	
# Called when the node enters the scene tree for the first time.
func onGenerate(isTriggered):
	var unset_tiles = Array()
	
	for i in range(map_y):
		for j in range(map_x):
			set_cell(j,i,default_tile)
			unset_tiles.push_back(Vector2(i,j))
	
	unset_tiles.shuffle()
	
	var set_tiles = Dictionary()
	
	var test = Array()
	
	for i in range(num_biomes):
			var sur_cells = Array()
			var power = starting_power
			var curr_biome = biomes[rand_range(0, biomes.size())]
			
			var checkTile = Vector2(rand_range(0,map_x),rand_range(0,map_y))
			while set_tiles.has(checkTile):
				checkTile = Vector2(rand_range(0,map_x),rand_range(0,map_y))
			
			sur_cells.push_back(checkTile)
			
			test.push_back([sur_cells,curr_biome])
	var temp = map_x * map_y
	while (not unset_tiles.empty()) and temp > 0:
			var biome_cells = test.pop_front()
			var sur_cells = biome_cells[0]
			sur_cells.shuffle()
			var curr_biome = biome_cells[1]
			
			print(sur_cells)
			print(curr_biome)
			var curr_cell = sur_cells.pop_front()
			
			
			
			var x = curr_cell.x
			var y = curr_cell.y
			print(test)
			set_cell(x,y,curr_biome)
			set_tiles[Vector2(x,y)] = curr_biome
			unset_tiles.erase(Vector2(x,y))
			
			temp -= 1
			
			sur_cells.push_back(Vector2(x,y-1))
			sur_cells.push_back(Vector2(x,y+1))
			sur_cells.push_back(Vector2(x-1,y))
			sur_cells.push_back(Vector2(x-1,y-1))
			sur_cells.push_back(Vector2(x+1,y-1))
			sur_cells.push_back(Vector2(x+1,y))
			test.push_back([sur_cells,curr_biome])
			
			
				
			
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
