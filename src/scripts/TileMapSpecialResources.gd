extends TileMapBase

var tiles: Array
var tiles_by_name: Dictionary

func _init().():
	var tiles = JsonParser.parse_json_file("res://resources/jsonconfigs/resources.json")
	if typeof(tiles) == TYPE_ARRAY:
		self.tiles = check_templates(tiles)
		self.tiles_by_name = Dictionary()
		self.tile_set = TileSet.new()
		var idx = 0
		for i in self.tiles:
			self.tiles_by_name[i["name"]] = i
			GlobalConfig.special_resources[i["name"]] = i
			self.tile_set.create_tile(idx)
			self.tile_set.tile_set_texture(idx,load(self.tiles[idx]["texture"]))
			self.tile_set.tile_set_region(idx,Rect2(Vector2(0,0),Vector2(32,48)))
			i["index"] = idx
			idx += 1
	
func generate():
	for i in GlobalConfig.map.keys():
		if rand_range(0,1) > 0.95:
			var biome = GlobalConfig.map[i]
			var special_tiles = Array()
			for j in tiles:
				if biome in j["tiles"]:
					special_tiles.append(j)
			if !special_tiles.empty():
				self.set_cellv(i,special_tiles[int(rand_range(0,special_tiles.size()-1))]["index"])
				GlobalConfig.special_resource_tiles[i] = self.tiles[self.get_cellv(i)]
				
func clear():
	GlobalConfig.special_resource_tiles.clear()
	for i in self.get_used_cells():
		self.set_cellv(i,-1)

func check_templates(templates):
	return templates
