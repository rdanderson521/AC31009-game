extends Player

class_name AI

var state: int
var unit_profiles: Dictionary
var city_profiles: Dictionary
var player_profiles: Dictionary

var attack_score: float
var defence_score: float
var city_score: float
var city_defence_score: float
var explore_score: float

var attack_priority: float
var defence_priority: float
var expand_priority: float
var explore_priority: float

var attack_bias: float
var defence_bias: float
var expand_bias: float

enum {EXPLORE,EXPAND,ATTACK,DEFEND}

func _init(start_hex:Vector2).(start_hex,true):
	self.unit_vis_range = 4
	self.building_vis_range = 5
	
	self.attack_score = 0
	self.defence_score = 0
	self.city_score = 0
	
	self.attack_priority = 0
	self.defence_priority = 0
	self.expand_priority = 0
	self.explore_priority = 0
	
	self.attack_bias = rand_range(0.5,2)
	self.defence_bias = rand_range(0.5,2)
	self.expand_bias = rand_range(0.5,2)
	
	self.state = EXPLORE
	self.unit_profiles = Dictionary()
	self.city_profiles = Dictionary()
	self.player_profiles = Dictionary()
	SignalManager.connect("move_wait_finished",self,"unit_turn_finished")
		
func turn_start():
	self.is_turn = true
	self.turn += 1
	
	units_attention_needed.clear()
	buildings_attention_needed.clear()
	
	if !units.empty():
		for i in self.units:
			unit_profiles[i].update_scores()
			if i.turn_start():
				units_attention_needed.push_back(i)
					
	if !buildings.empty():
		for i in self.buildings:
			city_profiles[i].update_scores()
			if i.turn_start():
				buildings_attention_needed.push_back(city_profiles[i])
			
	self.turn_decisions()

func turn_end():
	print("player end turn")
	var all_units_done = true
	if is_turn:
		is_turn = false
		selected_object = null
		units_attention_needed.clear()
	if !is_turn:
		
		for i in units:
			if !i.turn_end():
				units_attention_needed.append(i)

		if units_attention_needed.empty():
			SignalManager.player_turn_ended(self)
		else: 
			print("error ending turn")
			
func unit_turn_finished(unit):
	if unit in self.units:
		print(units_attention_needed)
		if unit in self.units_attention_needed:
			self.units_attention_needed.erase(unit)
			print(units_attention_needed)
			self.turn_end()
		
		
func new_unit(unit:Unit):
	self.add_child(unit)
	self.units.append(unit)
	self.unit_profiles[unit] = UnitProfile.new(unit,self)
	self.reset_visible()
	if unit.turn_start():
		self.units_attention_needed.append(unit)
		
func new_building(building:Building):
	self.add_child(building)
	self.buildings.append(building)
	if building.is_city:
		self.city_profiles[building] = CityProfile.new(building,self)
	self.reset_visible()
	if building.turn_start():
		if building.is_city:
			self.buildings_attention_needed.append(self.city_profiles[building])
		
func kill(obj:GameObject):
	if obj is Unit:
		self.units.erase(obj)
		self.unit_profiles.erase(obj)
		if obj in units_attention_needed:
			units_attention_needed.erase(obj)
		if obj == selected_object:
			self.selected_object = null
			
	elif obj is Building:
		self.buildings.erase(obj)
		self.city_profiles.erase(obj)
		if obj == selected_object:
			self.selected_object = null

##################### AI code below ########################

func turn_decisions():
	self.update_scores()
	for i in self.units_attention_needed:
		print(self.unit_profiles[i].unit.type)
		self.unit_profiles[i].select_task()
	
	for i in self.buildings_attention_needed:
		print(i.city.type)
		i.select_task()
		
		
	self.turn_end()
	
func update_scores():
	self.attack_score = 0
	self.defence_score = 0
	self.city_score = 0
	self.city_defence_score = 0
	self.explore_score = 0
	
	for i in self.unit_profiles.values():
		i.update_scores()
		self.attack_score += i.attack_score
		self.defence_score += i.defence_score
		
	for i in self.city_profiles.values():
		i.update_scores()
		self.city_defence_score += i.defence_score + i.unit_defence_score
		self.city_score += i.value_score
		
	self.update_player_profiles()
		
	self.explore_score = (self.not_fow.size()/max(1,self.fow.size())) + (self.visible_tiles.size()/(GlobalConfig.map_size.x*GlobalConfig.map_size.y))
	
	print(self.name,": ",self.attack_score,", ",self.defence_score,", ",self.city_score,", ",self.city_defence_score,", ",self.explore_score)


func update_player_profiles():
	for i in visible_tiles:
		if GlobalConfig.unit_tiles.has(i):
			var unit = GlobalConfig.unit_tiles[i]
			if !unit in self.units:
				var unit_parent = unit.get_parent()
				if self.player_profiles.has(unit_parent):
					self.player_profiles[unit_parent].update_unit(unit)
				else:
					var new_profile = PlayerProfile.new(unit_parent)
					self.player_profiles[unit_parent] = new_profile
					new_profile.update_unit(unit)
	for i in player_profiles.values():
		i.update_scores()


class UnitProfile:
	var player
	var is_own: bool
	var unit: Unit
	var attack_score: float
	var defence_score: float
	var explore_score: float
	var is_builder: bool
	var need_to_move: bool
	
	
	func _init(u: Unit, p):
		self.unit = u
		self.player = p
		SignalManager.connect("make_unit_move",self,"move_out_of_way")
		
		if self.unit.can_build or self.unit.can_build_city:
			self.is_builder = true
		else:
			self.is_builder = false
			
		self.need_to_move = false
			
		self.update_scores()
		
	func update_scores():
		self.attack_score = ((self.unit.attack * self.unit.attack_range * 0.75) * (self.unit.health / self.unit.health_max))
		self.defence_score = (self.unit.defence * (self.unit.health / self.unit.health_max))
		self.explore_score = (self.unit.move_range * (self.unit.health / self.unit.health_max))
		
	func select_task():
		if self.is_builder:
			self.builder_select_task()
		else:
			self.unit.explore(self.player.fow)
	
	
	func builder_select_task():
		if self.unit.can_build_city and self.unit.can_build: ################### CHANGE: make ai build buildings around city if not building city
			var new_city_location = self.find_new_city_location()
			if new_city_location == null:
				#self.explore()
				print("explore")
			else:
				if self.unit.hex_pos == new_city_location:
					self.unit.start_build("city")
				else:
					if !self.unit.find_path(new_city_location):
						if GlobalConfig.unit_tiles[new_city_location].get_parent() == self.player:
							SignalManager.make_unit_move(GlobalConfig.unit_tiles[new_city_location],self.unit)
		elif self.unit.can_build_city:
			var new_city_location = self.find_new_city_location()
			if new_city_location == null:
				#self.explore()
				print("explore")
			else:
				if self.unit.hex_pos == new_city_location:
					self.unit.start_build("city")
				else:
					if !self.unit.find_path(new_city_location):
						if GlobalConfig.unit_tiles[new_city_location].get_parent() == self.player:
							SignalManager.make_unit_move(GlobalConfig.unit_tiles[new_city_location],self.unit)
		elif self.unit.can_build:
			pass
	
	func move_out_of_way(u,u_sender):
		if u == self.unit and u_sender == self.player:
			#if self.unit.moves_left > 0:
				var locations = Hex.hex_in_range(1,self.unit.hex_pos)
				locations.erase(self.unit.hex_pos)
				locations.shuffle()
				for i in locations:
					if self.unit.find_path(i):
						break
			
	
	
	static func sort_city_locations(a,b):
		if a["total"] < b["total"]:
			return true
		return false
			
	func find_new_city_location():
		var city_locations = Array()
		for i in player.visible_tiles:
			if !GlobalConfig.map.has(i):
				continue
			if GlobalConfig.map[i] in GlobalConfig.water_biomes or GlobalConfig.map[i] in GlobalConfig.impasible_biomes:
				continue
			var city_start_area = Hex.hex_in_range(1,i)
			var area_valid = true
			var area_score = {"food":0,"construction":0,"defence":0}
			#print("checking location:" +str(i))
			for j in city_start_area:
				if !GlobalConfig.map.has(j):
					area_valid = false
					break
				if !j in player.visible_tiles:
					area_valid = false
					break
				area_score["food"] += GlobalConfig.biome_resources[GlobalConfig.map[j]]["food"]
				area_score["construction"] += GlobalConfig.biome_resources[GlobalConfig.map[j]]["construction"]
				if GlobalConfig.map[j] in GlobalConfig.impasible_biomes:
					area_score["defence"] += 1
			if area_valid:
				area_score["total"] = (area_score["food"] + area_score["construction"] + (5* area_score["defence"]) - Hex.hex_distance(self.unit.hex_pos,i))
				area_score["area"] = i
				city_locations.append(area_score)
		if !city_locations.empty():
			city_locations.sort_custom(UnitProfile,"sort_city_locations")
			return city_locations.back()["area"]
		return null
		
		
class CityProfile:
	var player
	var is_own: bool
	var city: Building
	var area: Array
	var buildings: Array
	var defence_score: float
	var unit_defence_score: float
	var unit_defence: Array
	var value_score: float
	
	func _init(b: Building, p):
		self.city = b
		self.player = p
		self.unit_defence = Array()
		self.area = b.area
			
		self.update_scores()
		
	func update_scores():
		self.defence_score = (self.city.defence * (self.city.health / self.city.health_max))
		
		self.value_score = 0
		var max_resources_required = Dictionary()
		for i in self.city.build_options.values():
			for j in i["cost"].keys():
				if max_resources_required.has(j):
					if max_resources_required[j] < i["cost"][j]:
						max_resources_required[j] = i["cost"][j]
				else:
					max_resources_required[j] = i["cost"][j]
		for i in self.city.resources_per_turn.keys():
			if i in max_resources_required.keys():
				self.value_score += self.city.resources_per_turn[i] + (max_resources_required[i]/self.city.resources_per_turn[i])
			else:
				self.value_score += self.city.resources_per_turn[i]/2
				
		update_unit_defence(self.player.unit_profiles.values())
		
		print("city def: ",self.defence_score+self.unit_defence_score," val: ", self.value_score)
		
	func update_unit_defence(unit_profiles):
		self.unit_defence_score = 0
		self.unit_defence.clear()
		for i in unit_profiles:
			var dist = Hex.hex_distance(i.unit.hex_pos,self.city.hex_pos)
			if dist < 5 and i.defence_score > 5:
				self.unit_defence_score += (i.defence_score/max(1,0.5*dist))
				self.unit_defence.append(i)
					
	func select_task(priority = EXPLORE):
		if self.city.can_build():
			var resources = self.city.resources_per_turn
			var build_options = self.city.build_options
			if priority == EXPLORE:
				var best_option
				var dist_per_turn = 0
				for i in build_options.values():
					if i["type"] == "Unit":
						var move_range = UnitFactory.unit_templates_by_name[i["name"]]["move_range"]
						var cost = i["cost"]
						var turns = -1
						for j in cost.keys():
							turns = max(turns,cost[j]/resources[j])
						if move_range/turns > dist_per_turn:
							dist_per_turn = move_range/turns
							best_option = i["name"]
				if city.can_build(best_option):
					city.start_build(best_option)
							
class PlayerProfile:
	var player
	var cities: Dictionary #[city] = {city,last_seen,city_cpy,updated}
	var units: Dictionary #[unit] = {unit,last_seen,unit_cpy,updated}
	
	var attack_score: float
	var defence_score: float
	var city_defence_score: float
	
	func _init(p):
		self.player = p
		units = Dictionary()
		cities = Dictionary()
		attack_score = 0
		defence_score = 0
		city_defence_score = 0
	
	func update_unit(unit):
		if units.has(unit):
			units[unit]["last_seen"] = 0
			units[unit]["unit_cpy"] = UnitFactory.copy_unit(unit)
			units[unit]["updated"] = true
		else:
			units[unit] = {"unit": unit, "last_seen": 0, "updated": true, "unit_cpy": UnitFactory.copy_unit(unit)}
			
	func update_scores():
		attack_score = 0
		defence_score = 0
		city_defence_score = 0
		for i in units.values():
			if !i["updated"]:
				i["last_seen"] += 1
			if i["last_seen"] > 10:
				units.erase(i)
			else:
				attack_score += (i["unit_cpy"].attack*i["unit_cpy"].health)/(max(1,i["last_seen"]) * i["unit_cpy"].health_max)
				defence_score = (i["unit_cpy"].defence*i["unit_cpy"].health)/(max(1,i["last_seen"]) * i["unit_cpy"].health_max)
		
		print("player profile atck: ",self.attack_score, " def: ", self.defence_score)
			
	func turn_start():
		for i in units.values():
			i["updated"] = false
		for i in cities.values():
			i["updated"] = false
			
		
	
	
	
