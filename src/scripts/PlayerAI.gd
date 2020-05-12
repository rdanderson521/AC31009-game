extends Player

class_name AI

var state: int
var unit_profiles: Dictionary
var city_profiles: Dictionary
var player_profiles: Dictionary
var units_assigned:Dictionary

var attack_score: float
var defence_score: float
var city_score: float
var city_defence_score: float
var explore_score: float

var assigned_attack_score: float
var assigned_defence_score: float
var assigned_city_defence_score: float
var assigned_explore_score: float

var attack_priority: Dictionary
var defence_priority: Dictionary
var expand_priority: Dictionary
var explore_priority: Dictionary

var priorities: Dictionary

var attack_bias: float
var defence_bias: float
var expand_bias: float
var explore_bias: float

var explore_target: CityProfile
var explore_type: int

var attack_target: PlayerProfile
var attack_type: int

var defence_type: int

enum attack{BUILD,MOVE,CITY,UNIT}
enum defence{BUILD,MOVE,PRIORITY}
enum expand{BUILD,CITY,IMPROVEMENT}
enum explore{BUILD,MOVE,CITY,FOW}

enum {EXPLORE,EXPAND,ATTACK,DEFEND}

func _init(start_hex:Vector2).(start_hex,true):
	self.unit_vis_range = 4
	self.building_vis_range = 5
	
	self.attack_score = 0
	self.defence_score = 0
	self.city_score = 0
	
	self.attack_priority = Dictionary()
	for i in attack:
		self.attack_priority[attack[i]] = 0
	self.defence_priority = Dictionary()
	for i in defence:
		self.defence_priority[defence[i]] = 0
	self.expand_priority = Dictionary()
	for i in expand:
		self.expand_priority[expand[i]] = 0
	self.explore_priority = Dictionary()
	for i in explore:
		self.explore_priority[explore[i]] = 0
		
	self.priorities = Dictionary()
	self.priorities[ATTACK] = self.attack_priority
	self.priorities[DEFEND] = self.defence_priority
	self.priorities[EXPLORE] = self.explore_priority
	self.priorities[EXPAND] = self.expand_priority
	
	self.attack_bias = rand_range(0.5,2)
	self.defence_bias = rand_range(0.5,2)
	self.expand_bias = rand_range(0.5,2)
	self.explore_bias = rand_range(0.5,2)
	
	self.state = EXPLORE
	self.unit_profiles = Dictionary()
	self.city_profiles = Dictionary()
	self.player_profiles = Dictionary()
	self.units_assigned = Dictionary()
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
				
	for i in player_profiles.values():
		i.turn_start()
			
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
		if unit in self.units_attention_needed:
			self.units_attention_needed.erase(unit)
			if self.units_attention_needed.empty():
				self.turn_end()
		
		
func new_unit(unit:Unit):
	#self.add_child(unit)
	self.units.append(unit)
	self.unit_profiles[unit] = UnitProfile.new(unit,self)
	self.reset_visible()
	if unit.turn_start():
		self.units_attention_needed.append(unit)
		
func new_building(building:Building):
	#self.add_child(building)
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
			
func unit_moved(unit:Unit,from:Vector2,to:Vector2):
	if unit in self.units:
		var old_visible = Hex.hex_in_range(self.unit_vis_range,from) 
		var new_visible = Hex.hex_in_range(self.unit_vis_range,to)
		
		for i in old_visible:
			if i in new_visible:
				new_visible.erase(i)
			else:
				self.visible_tiles.erase(i)
				
		self.check_tiles_for_enemy(new_visible)
		for i in new_visible:
			self.visible_tiles.append(i)
			if i in self.fow:
				self.fow.erase(i)

##################### AI code below ########################

func turn_decisions():
	self.update_scores()
	
	for i in self.units:
		if !self.units_assigned.has(i):
			self.units_assigned[i] = null
		if i.can_build or i.can_build_city:
			self.units_assigned[i] = EXPAND
		if self.units_assigned[i] == null:
			self.units_assigned[i] = self.unit_profiles[i].unit_type()
	
	for i in self.units:
		if self.units_assigned[i] == ATTACK:
			if self.units_assigned.values().count(ATTACK) > 1 and max(self.attack_priority[attack.CITY],self.attack_priority[attack.UNIT]) < self.defence_priority[defence.MOVE]:
				self.units_assigned[i] = DEFEND
				self.update_scores()
				
			
	for i in self.units_attention_needed:
		if self.units_assigned[i] == EXPLORE:
			if self.explore_priority[explore.FOW] > self.explore_priority[explore.CITY]:
				self.unit_profiles[i].explore_fow()
			else:
				self.unit_profiles[i].go_to_object(explore_target.city)
		elif self.units_assigned[i] == ATTACK:
			if self.attack_target != null:
				if self.attack_priority[attack.CITY] > self.attack_priority[attack.UNIT]:
					var target_cities = self.attack_target.get_cities()
					if !target_cities.empty():
						self.unit_profiles[i].attack_city(target_cities.front()["building"])
				else:
					var target_units = self.attack_target.units
					if !target_units.empty():
						var unit_to_attack
						var distance = -1
						for j in target_units.values():
							if distance == -1 or distance > Hex.hex_distance(j["unit_cpy"].hex_pos,i.hex_pos) + j["last_seen"]:
								unit_to_attack = j
								distance = Hex.hex_distance(j["unit_cpy"].hex_pos,i.hex_pos) + j["last_seen"]
						self.unit_profiles[i].attack_unit(unit_to_attack["unit"])
		elif self.units_assigned[i] == DEFEND:
			self.unit_profiles[i].go_to_object(self.city_profiles[self.buildings.front()].city)
		elif self.units_assigned[i] == EXPAND:
			self.unit_profiles[i].select_task()
		
		
		
	
	var total_build_priority = self.attack_priority[attack.BUILD] + self.defence_priority[defence.BUILD] + self.explore_priority[explore.BUILD] + self.expand_priority[expand.BUILD]
	var build_unit_priorities = {ATTACK:self.attack_priority[attack.BUILD]/total_build_priority,DEFEND:self.defence_priority[defence.BUILD]/total_build_priority,
		EXPAND:self.expand_priority[expand.BUILD]/total_build_priority,EXPLORE:self.explore_priority[explore.BUILD]/total_build_priority}
	
	var buildings_ready = self.buildings_attention_needed.size()
	for i in self.buildings_attention_needed:
		var highest_priority_unit = 0
		for j in build_unit_priorities.keys():
			if build_unit_priorities[j] > highest_priority_unit:
				highest_priority_unit = j
		print("building unit: ",highest_priority_unit)
		build_unit_priorities[highest_priority_unit] -= 1/buildings_ready
		
		i.select_task(highest_priority_unit)
		
		
	self.turn_end()
	
func update_scores():
	self.attack_score = 0
	self.defence_score = 0
	self.city_score = 0
	self.city_defence_score = 0
	self.explore_score = 0
	
	self.assigned_attack_score = 0
	self.assigned_defence_score = 0
	self.assigned_city_defence_score = 0
	self.assigned_explore_score = 0
	
	for i in self.unit_profiles.values():
		i.update_scores()
		self.attack_score += i.attack_score
		self.defence_score += i.defence_score
		self.explore_score += i.explore_score
		if self.units_assigned.has(i.unit):
			if self.units_assigned[i.unit] == EXPLORE:
				self.assigned_explore_score += i.explore_score
			elif self.units_assigned[i.unit] == ATTACK:
				self.assigned_attack_score += i.attack_score
			elif self.units_assigned[i.unit] == DEFEND:
				self.assigned_defence_score += i.defence_score
		else:
			self.units_assigned[i.unit] = null
		
	for i in self.city_profiles.values():
		i.update_scores()
		self.city_defence_score += i.defence_score + i.unit_defence_score
		self.city_score += i.value_score
		
	self.update_player_profiles()
	
	print(self.name," scores: ",self.attack_score,", ",self.defence_score,", ",self.city_score,", ",self.city_defence_score,", ",self.explore_score)
	
	for i in self.explore_priority.keys():
		self.explore_priority[i] = 0
	for i in player_profiles.values():
		for j in i.get_cities():
			if self.explore_priority[explore.CITY] < j["last_seen"]/min(self.turn,20):
				self.explore_priority[explore.CITY] = j["last_seen"]/min(self.turn,20)
				self.explore_target = j
				self.explore_type = explore.CITY
				
	print(float(self.fow.size())/float(GlobalConfig.map.size()))
	if self.explore_priority[explore.FOW] < float(self.fow.size())/float(GlobalConfig.map.size()):
		self.explore_priority[explore.FOW] = float(self.fow.size())/float(GlobalConfig.map.size())
		self.explore_target = null
		self.explore_type = explore.FOW
		
	self.explore_priority[explore.BUILD] = (max(self.explore_priority[explore.FOW],self.explore_priority[explore.CITY])/max(self.assigned_explore_score,1)) * self.explore_bias
	print("explore type: ",self.explore_type," priority: ", self.explore_priority)
	
	for i in self.attack_priority.keys():
		self.attack_priority[i] = 0
	for i in self.defence_priority.keys():
		self.defence_priority[i] = 0
		
	self.defence_type = defence.BUILD
	var total_aggression = 0
	var max_aggression = 0
	var max_aggressor = null
	
	for i in player_profiles.values():
		total_aggression += i.aggression
		if max_aggression < i.aggression:
			max_aggression = i.aggression
			max_aggressor = i
		if i.city_defence_score > 0:
			if (self.attack_score/(2*max(1,i.city_defence_score))) > self.attack_priority[attack.CITY]:
				self.attack_priority[attack.CITY] = (self.attack_score/(2*max(1,i.city_defence_score)))
				self.attack_target = i
			if (i.city_defence_score/self.attack_score) > self.attack_priority[attack.BUILD]:
				self.attack_priority[attack.BUILD] = (i.city_defence_score/self.attack_score)
		
		if self.city_defence_score > 0 and i.attack_score > 0:
			if  max(i.aggression/i.attack_score,0.5)*(i.attack_score/self.city_defence_score) > self.attack_priority[attack.UNIT]:
				self.attack_priority[attack.UNIT] = max(i.aggression/i.attack_score,0.5)*(i.attack_score/self.city_defence_score)
			if  max(i.aggression/i.attack_score,0.5)*(i.attack_score/self.attack_score) > self.attack_priority[attack.BUILD]:
				self.attack_priority[attack.BUILD] = max(i.aggression/i.attack_score,0.5)*(i.attack_score/self.attack_score)
			
		if self.defence_score > 0 and i.attack_score > 0:
			if max(i.aggression/i.attack_score,0.5)*(i.attack_score/self.defence_score) > self.attack_priority[attack.UNIT]:
				self.attack_priority[attack.UNIT] = max(i.aggression/i.attack_score,0.5)*(i.attack_score/self.defence_score)
			
			if max(i.aggression/i.attack_score,0.5)*(i.attack_score/self.attack_score) > self.attack_priority[attack.BUILD]:
				self.attack_priority[attack.BUILD] = max(i.aggression/i.attack_score,0.5)*(i.attack_score/self.attack_score)
		
		if self.city_defence_score > 0 and i.attack_score > 0:
			var new_defence_priority = (max(i.aggression/i.attack_score,0.5)*i.attack_score)/(self.city_defence_score)#max(i.aggression/defence,i.attack_score/defence)#max(0.2,i.aggression) * max(i.attack_score/defence,0)
			if new_defence_priority > self.defence_priority[defence.PRIORITY]:
				self.defence_priority[defence.PRIORITY] = new_defence_priority
	
	self.attack_priority[attack.UNIT] = self.attack_priority[attack.UNIT] * self.attack_bias
	self.attack_priority[attack.CITY] = self.attack_priority[attack.CITY] * self.attack_bias
	
	self.defence_priority[defence.PRIORITY] = self.defence_priority[defence.PRIORITY] * self.defence_bias
	
	self.defence_priority[defence.MOVE] = (self.defence_score / max(1,self.assigned_defence_score))*self.defence_priority[defence.PRIORITY]
	if self.defence_score > 0:
		self.defence_priority[defence.BUILD] = (self.assigned_defence_score / self.defence_score)*self.defence_priority[defence.PRIORITY]

	print("defence type: ",self.defence_type," priority: ", self.defence_priority)
	print("attack priority: ", self.attack_priority)
			
func update_player_profiles():
	self.check_tiles_for_enemy(self.visible_tiles)
	
	for i in player_profiles.values():
		i.update_scores()

func check_tiles_for_enemy(tiles):
	for i in tiles:
		if GlobalConfig.unit_tiles.has(i):
			var unit = GlobalConfig.unit_tiles[i]
			if !unit in self.units:
				var unit_parent = unit.get_parent()
				if unit_parent != null:
					if self.player_profiles.has(unit_parent):
						self.player_profiles[unit_parent].update_unit(unit)
					else:
						var new_profile = PlayerProfile.new(unit_parent,self)
						self.player_profiles[unit_parent] = new_profile
						new_profile.update_unit(unit)
		if GlobalConfig.building_tiles.has(i):
			var building = GlobalConfig.building_tiles[i]
			if !building in self.buildings:
				var building_parent = building.get_parent()
				if building_parent != null:
					if self.player_profiles.has(building_parent):
						self.player_profiles[building_parent].update_building(building)
					else:
						var new_profile = PlayerProfile.new(building_parent,self)
						self.player_profiles[building_parent] = new_profile
						new_profile.update_building(building)

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
		
	func unit_type():
		if self.is_builder:
			return EXPAND
		if self.attack_score > self.defence_score:
			if self.attack_score > self.explore_score:
				return ATTACK
			else:
				return EXPLORE
		else:
			if self.defence_score > self.explore_score:
				return DEFEND
			else:
				return EXPLORE
		
	func update_scores():
		self.attack_score = ((self.unit.attack * self.unit.attack_range * 0.75) * (self.unit.health / self.unit.health_max)) + self.unit.attack
		self.defence_score = (self.unit.defence * (self.unit.health / self.unit.health_max)) + self.unit.defence
		self.explore_score = (self.unit.move_range * (self.unit.health / self.unit.health_max)) + (self.unit.move_range*2)
		
	func select_task():
		if self.is_builder:
			self.builder_select_task()
		else:
			self.unit.explore(self.player.fow)
	
	func go_to_object(object,dist = 3):
		var closest_hex = Hex.closest_hex_in_range(object.hex_pos,dist,self.unit.hex_pos)
		if !self.unit.find_path(closest_hex):
			var near_hex = Hex.hex_in_range(dist,object.hex_pos)
			near_hex.shuffle()
			for i in near_hex:
				if dist > 1:
					if Hex.hex_distance(i,object.hex_pos) <= 1:
						continue
				if self.unit.find_path(i):
					return true
		else:
			return true
		return false
		
	func attack_city(city):
		print("atack city")
		if self.unit.attack_range >= Hex.hex_distance(self.unit.hex_pos,city.hex_pos):
			print("attacking")
			self.unit.attack(city)
		else:
			self.go_to_object(city,self.unit.attack_range)
			
	func attack_unit(enemy):
		print("atack city")
		if self.unit.attack_range >= Hex.hex_distance(self.unit.hex_pos,enemy.hex_pos):
			print("attacking")
			self.unit.attack(enemy)
		else:
			self.go_to_object(enemy,self.unit.attack_range)
			
	func explore_fow(dist=10):
		var start_time = OS.get_ticks_msec()
		if !self.player.fow.empty():
			var fow = self.player.fow.duplicate()
			var player_center = Vector2(0,0)
			var player_center_input = 0
			if !self.player.area.empty():
				for i in self.player.area:
					player_center += i
					player_center_input += 1
			else:
				for i in self.player.units:
					if i == self.unit:
						continue
					player_center += i.hex_pos
					player_center_input += 1
			player_center = player_center/player_center_input
			
			var found = false
			var idx = 0
			while !found and !fow.empty():
				idx += 1
				var search_area = Hex.hex_in_range(dist*idx,player_center)
				if self.player.not_fow.size() > 0.8*search_area.size():
					continue
				fow.shuffle()
				for i in fow:
					if i in search_area:
						if self.unit.find_path(i):
							found = true
							break
						else:
							fow.erase(i)
			print("time taken explore: ", OS.get_ticks_msec()-start_time)
	
	func builder_select_task():
		if self.unit.can_build_city and self.unit.can_build: ################### CHANGE: make ai build buildings around city if not building city
			var new_city_location = self.find_new_city_location()
			if new_city_location == null:
				self.unit.explore()
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
				self.unit.explore()
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
			if dist < 5 :
				self.unit_defence_score += (i.defence_score/max(1,0.5*dist))
				self.unit_defence.append(i)
					
	func select_task(priority = EXPLORE):
		if self.city.can_build():
			if priority == EXPLORE:
				self.build_explore_unit()
			elif priority == ATTACK:
				self.build_attack_unit()
			elif priority == DEFEND:
				self.build_defence_unit()
			elif priority == EXPAND:
				pass
				
	func build_explore_unit():
		var resources = self.city.resources_per_turn
		var build_options = self.city.build_options
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
		print(best_option)
		if city.can_build(best_option):
			city.start_build(best_option)
			
	func build_attack_unit():
		var resources = self.city.resources_per_turn
		var build_options = self.city.build_options
		var best_option
		var attack_per_turn = 0
		for i in build_options.values():
			if i["type"] == "Unit":
				var attack = UnitFactory.unit_templates_by_name[i["name"]]["damage"]
				var cost = i["cost"]
				var turns = -1
				for j in cost.keys():
					turns = max(turns,cost[j]/resources[j])
				if attack/turns > attack_per_turn:
					attack_per_turn = attack/turns
					best_option = i["name"]
		print(best_option)
		if city.can_build(best_option):
			city.start_build(best_option)
			
	func build_defence_unit():
		var resources = self.city.resources_per_turn
		var build_options = self.city.build_options
		var best_option
		var defence_per_turn = 0
		for i in build_options.values():
			if i["type"] == "Unit":
				var defence = UnitFactory.unit_templates_by_name[i["name"]]["defence"]
				var cost = i["cost"]
				var turns = -1
				for j in cost.keys():
					turns = max(turns,cost[j]/resources[j])
				if defence/turns > defence_per_turn:
					defence_per_turn = defence/turns
					best_option = i["name"]
		print(best_option)
		if city.can_build(best_option):
			city.start_build(best_option)
							
class PlayerProfile:
	var enemy
	var player
	var buildings: Dictionary #[city] = {city,last_seen,city_cpy,updated}
	var units: Dictionary #[unit] = {unit,last_seen,unit_cpy,updated}
	
	var attack_score: float
	var defence_score: float
	var city_defence_score: float
	var aggression: float
	
	func _init(e,p):
		self.enemy = e
		self.player = p
		units = Dictionary()
		buildings = Dictionary()
		attack_score = 0
		defence_score = 0
		city_defence_score = 0
		SignalManager.connect("kill_unit",self,"unit_killed")
		SignalManager.connect("kill_building",self,"building_killed")
		
	func get_cities():
		return self.buildings.values()
	
	func update_unit(unit):
		if units.has(unit):
			if !units[unit]["updated"] or units[unit]["last_seen"] > 0:
				units[unit]["last_seen"] = 0
				units[unit]["unit_cpy"] = UnitFactory.copy_unit(unit)
				units[unit]["updated"] = true
		else:
			units[unit] = {"unit": unit, "last_seen": 0, "updated": true, "unit_cpy": UnitFactory.copy_unit(unit)}
			
		for i in player.buildings:
			if Hex.hex_distance(i.hex_pos,unit.hex_pos) <= 4:
				self.aggression += unit.attack/max(1,(Hex.hex_distance(i.hex_pos,unit.hex_pos)))
				
	func update_building(building):
		if buildings.has(building):
			if !buildings[building]["updated"] or buildings[building]["last_seen"] > 0:
				buildings[building]["last_seen"] = 0
				buildings[building]["building_cpy"] = BuildingFactory.copy_building(building)
				buildings[building]["updated"] = true
		else:
			buildings[building] = {"building": building, "last_seen": 0, "updated": true, "building_cpy": BuildingFactory.copy_building(building)}
			
			
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
				defence_score += (i["unit_cpy"].defence*i["unit_cpy"].health)/(max(1,i["last_seen"]) * i["unit_cpy"].health_max)
		for i in buildings.values():
			self.city_defence_score += i["building_cpy"].defence
			if i["building_cpy"].is_city:
				for j in units.values():
					var dist = Hex.hex_distance(j["unit_cpy"].hex_pos,i["building_cpy"].hex_pos)
					if dist < 5:
						self.city_defence_score += j["unit_cpy"].defence/(max(1,0.5*dist)*max(1,j["last_seen"]))
		print(self.enemy.get_name()," profile atck: ",self.attack_score, " def: ", self.defence_score, " city_def: ", self.city_defence_score, " agr: ", self.aggression)
			
			
	func turn_start():
		if aggression > 0:
			aggression = min(aggression*0.9,aggression-1)
		for i in units.values():
			i["updated"] = false
		for i in buildings.values():
			i["updated"] = false
			
	func unit_killed(unit):
		if self.units.has(unit):
			units.erase(unit)
			
	func building_killed(building):
		if self.buildings.has(building):
			buildings.erase(building)
		
			
		
	
	
	
