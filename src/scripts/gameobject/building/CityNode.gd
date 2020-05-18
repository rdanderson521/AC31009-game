extends Building

class_name City

var area: Array
var resources_per_turn: Dictionary
var buildings: Array
var building_tiles: Dictionary

func _init():
	self.building_tiles = Dictionary()
	SignalManager.connect("kill_building",self,"kill_building")

func _ready():
	self.build_options_outdated = true
	self.update_resources()
	self.update_build_options()
	
func turn_start() -> bool:
	if self.mode == BUILD:
		var build_finished = true
		for i in self.build_resources_left.keys():
			print("key: " + str(i))
			self.build_resources_left[i] -= self.resources_per_turn[i]
			print(self.build_resources_left[i])
			if self.build_resources_left[i] > 0:
				build_finished = false
		
		if build_finished:
			self.build_resources_left = Dictionary()
			var new_unit = UnitFactory.build_unit(self.build_curr,self.hex_pos,self.get_parent())
			self.get_parent().new_unit(new_unit)
			self.mode = DEFAULT
		else:
			return false
	self.update_build_options()
	return true
	
func add_building(building:Building):
	self.buildings.append(building)
	self.building_tiles[building.hex_pos] = building
	for i in building.improvements.keys():
		if self.resources_per_turn.has(i):
			self.resources_per_turn[i] += building.improvements[i]
		else:
			self.resources_per_turn[i] = building.improvements[i]
	if GlobalConfig.special_resource_tiles.has(building.hex_pos) and GlobalConfig.special_resource_tiles[building.hex_pos]["building"].has(building.type):
		var special_resources = GlobalConfig.special_resource_tiles[self.hex_pos]["improvements"]
		print("special building made")
		for i in special_resources.keys():
			if self.resources_per_turn.keys().has(i):
				self.resources_per_turn[i] += special_resources[i]
			else:
				self.resources_per_turn[i] = special_resources[i]
				
func update_resources():
	for i in self.area:
		var tile_resources =  GlobalConfig.biome_resources[GlobalConfig.map[i]]
		for j in tile_resources.keys():
			if self.resources_per_turn.has(j):
				self.resources_per_turn[j] += tile_resources[j]
			else:
				self.resources_per_turn[j] = tile_resources[j]
					
	for i in self.improvements.keys():
		if self.resources_per_turn.keys().has(i):
			self.resources_per_turn[i] += improvements[i]
		else:
			self.resources_per_turn[i] = improvements[i]
			
	if self.hex_pos in GlobalConfig.special_resource_tiles.keys():
		var special_resources = GlobalConfig.special_resource_tiles[self.hex_pos]["improvements"]
		for i in special_resources.keys():
			if self.resources_per_turn.keys().has(i):
				self.resources_per_turn[i] += special_resources[i]
			else:
				self.resources_per_turn[i] = special_resources[i]
	
func can_build(building = null) -> bool:
	if self.mode == BUILD:
		return false
	elif self.mode == DEFAULT and building == null:
		return true
	if building != null:
		self.update_build_options()
		if self.build_options.has(building):
			var cost = self.build_options[building]["cost"]
			for i in cost.keys():
				if !i in self.resources_per_turn.keys():
					return false
				elif resources_per_turn[i] <= 0:
					return false
			return true
	return false
	
func start_build(building_name:String):
	if self.can_build(building_name):
		if self.build_options.has(building_name):
			print("building start unit")
			self.build_resources_left = self.build_options[building_name]["cost"].duplicate()
			self.build_curr = building_name
			self.mode = BUILD
			self.update_build_options()
			SignalManager.building_build_start(self)
	else:
		return false
		
func update_build_options():
	self.build_options.clear()
	for i in UnitFactory.unit_templates:
		self.build_options[i["name"]] = i.duplicate(true)
		self.build_options[i["name"]]["type"]  = "Unit"
		if self.mode == BUILD:
			self.build_options[i["name"]]["enabled"] = false
		else:
			self.build_options[i["name"]]["enabled"] = true
	SignalManager.build_options_updated(self)
	
func kill_building(building):
	if self.buildings.has(building):
		self.building_tiles.erase(building.hex_pos)
		self.buildings.erase(building)
		self.update_resources()

func _draw():
	print("draw city")
	for i in self.area:
		var points = Array()
		var pos = Hex.hex_to_point(i)
		points.append(pos + Vector2(-Hex.width/4,-Hex.height/2)-self.position)
		points.append(pos + Vector2(Hex.width/4,-Hex.height/2)-self.position)
		points.append(pos + Vector2(Hex.width/2,0)-self.position)
		points.append(pos + Vector2(Hex.width/4,Hex.height/2)-self.position)
		points.append(pos + Vector2(-Hex.width/4,Hex.height/2)-self.position)
		points.append(pos + Vector2(-Hex.width/2,0)-self.position)
		var polygon = PoolVector2Array(points)
		draw_polygon(polygon,PoolColorArray([self.get_parent().colour]))

