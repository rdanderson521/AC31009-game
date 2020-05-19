extends Player

class_name AI

var state: int
var unit_profiles: Dictionary
var city_profiles: Dictionary
var player_profiles: Dictionary
var units_assigned:Dictionary
var unit_targets:Dictionary

var attack_score: float
var defence_score: float
var city_score: float
var city_defence_score: float
var expand_score: float
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

#var explore_target: CityProfile
var explore_type: int

var attack_target: PlayerProfile
var attack_type: int

var defence_type: int

enum attack{BUILD,CITY,UNIT}
enum defence{BUILD,CITY}
enum expand{BUILD_CITY,BUILD_IMPROVE,CITY,IMPROVEMENT}
enum explore {BUILD,CITY,FOW}

enum {EXPLORE,EXPAND,ATTACK,DEFEND}

enum build{EXPAND_CITY,EXPAND_IMPROVE,EXPLORE,ATTACK,DEFEND}

func _init(start_hex:Vector2).(start_hex):
	self.unit_vis_range = 4
	self.building_vis_range = 5
	
	self.attack_score = 0
	self.defence_score = 0
	self.city_score = 0
	
	self.attack_priority = Dictionary()
	for i in self.attack:
		self.attack_priority[attack[i]] = 0
	self.defence_priority = Dictionary()
	for i in self.defence:
		self.defence_priority[defence[i]] = 0
	self.expand_priority = Dictionary()
	for i in self.expand:
		self.expand_priority[expand[i]] = 0
	self.explore_priority = Dictionary()
	for i in self.explore :
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
	self.unit_targets = Dictionary()
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
			if i is City:
				city_profiles[i].update_scores()
				if i.turn_start():
					buildings_attention_needed.push_back(city_profiles[i])
				
	for i in player_profiles.values():
		i.turn_start()
	
	SignalManager.player_turn_started(self)
			
	self.turn_decisions()

func turn_end():
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
			if self.units_attention_needed.empty():# and self.buildings_attention_needed.empty():
				self.turn_end()
		
		
func new_unit(unit:Unit):
	self.add_child(unit)
	#self.add_child(unit)
	self.units.append(unit)
	self.unit_profiles[unit] = UnitProfile.new(unit,self)
	self.reset_visible()
	if unit.turn_start():
		self.units_attention_needed.append(unit)
		
func new_building(building:Building):
	self.buildings.append(building)
	GlobalConfig.building_tiles[building.hex_pos] = building
	if building is City:
		GlobalConfig.city_tiles[building.hex_pos] = building
		self.cities.append(building)
		for i in building.area:
			self.area.append(i)
			self.city_area[i] = building
		self.city_profiles[building] = CityProfile.new(building,self)
	else:
		if self.city_area.has(building.hex_pos):
			self.city_area[building.hex_pos].add_building(building)
			self.city_profiles[self.city_area[building.hex_pos]].add_building(building)
			
	self.visible_tiles += Hex.hex_in_range(self.building_vis_range,building.hex_pos)
	if building.turn_start():
		if building is City:
			self.buildings_attention_needed.append(self.city_profiles[building])
		
func kill(obj:GameObject):
	if obj is Unit:
		self.units.erase(obj)
		self.unit_profiles.erase(obj)
		if obj in self.units_attention_needed:
			self.units_attention_needed.erase(obj)
		if obj in self.units_assigned:
			self.units_assigned.erase(obj)
		if obj == self.selected_object:
			self.selected_object = null
			
	elif obj is Building:
		self.buildings.erase(obj)
		if obj in self.buildings_attention_needed:
			self.buildings_attention_needed.erase(obj)
		if obj is City:
			self.city_profiles.erase(obj)
			self.cities.erase(obj)
			for i in obj.buildings:
				i.kill()
		if obj == self.selected_object:
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
	self.units_assigned.clear()
	
	self.update_scores()
	self.update_priorities()
	
	var total_priority = 0
	
	var total_attack_priority = 0
	for i in self.attack_priority:
		if i in [attack.CITY,attack.UNIT]:
			for j in self.attack_priority[i]:
				total_attack_priority += self.attack_priority[i][j]
	print("total attack pri: ",total_attack_priority)
	total_priority += total_attack_priority
				
	var total_defence_priority = 0
	for i in self.defence_priority:
		if i in [defence.CITY]:
			for j in self.defence_priority[i]:
				total_defence_priority += self.defence_priority[i][j]
	print("total defence pri: ",total_defence_priority)
	total_priority += total_defence_priority
	
	var total_explore_priority = 0
	for i in self.explore_priority:
		if i in [explore.CITY]:
			for j in self.explore_priority[i]:
				total_explore_priority += self.explore_priority[i][j]
		elif i in [explore.FOW]:
			total_explore_priority += self.explore_priority[i]
	print("total explore pri: ",total_explore_priority)
	total_priority += total_explore_priority
	
	var total_expand_priority = 0
	for i in self.expand_priority:
		if i in [expand.IMPROVEMENT]:
			for j in self.expand_priority[i]:
				total_expand_priority += self.expand_priority[i][j]
		elif i in [expand.CITY]:
			total_expand_priority += self.expand_priority[i]
	print("total expand pri: ",total_expand_priority)
	total_priority += total_expand_priority
	
	var num_units = self.units.size()
	var unassigned_units = Array()
	for i in self.units:
#		if !self.units_assigned.has(i):
#			self.units_assigned[i] = null
			
		if i.can_build_city and self.expand_priority[expand.CITY] > 0:
			self.units_assigned[i] = EXPAND
			total_expand_priority -= total_priority/num_units
			self.expand_priority[expand.CITY] -= total_priority/num_units
		elif i.can_build:
			self.units_assigned[i] = EXPAND
			var improvement_city = null
			for j in self.expand_priority[expand.IMPROVEMENT]:
				if improvement_city == null:
					improvement_city = j
				else:
					if self.expand_priority[expand.IMPROVEMENT][j] > self.expand_priority[expand.IMPROVEMENT][improvement_city]:
						improvement_city = j
			if improvement_city != null:
				self.unit_targets[i] = improvement_city
				self.expand_priority[expand.IMPROVEMENT][improvement_city] -= total_priority/num_units
				total_expand_priority -= total_priority/num_units
			else:
				unassigned_units.append(i)
		else:
			unassigned_units.append(i)
	
	while !unassigned_units.empty():
		print("unassigned units: ", unassigned_units)
		var max_priority
		var max_priority_type
		var max_priority_target = null
		var max_priority_value = 0
		for i in self.explore_priority:
			if i == explore.FOW:
				if  self.explore_priority[i] > max_priority_value:
					max_priority_value = self.explore_priority[i] 
					max_priority = EXPLORE
					max_priority_type = i
					max_priority_target = null
			elif i == explore.CITY:
				for j in self.explore_priority[i]:
					if  self.explore_priority[i][j] > max_priority_value:
						max_priority_value = self.explore_priority[i][j]
						max_priority = EXPLORE
						max_priority_type = i
						max_priority_target = j
						
		for i in self.attack_priority:
			if i in [attack.CITY,attack.UNIT]:
				for j in self.attack_priority[i]:
					if  self.attack_priority[i][j] > max_priority_value:
						max_priority_value = self.attack_priority[i][j]
						max_priority = ATTACK
						max_priority_type = i
						max_priority_target = j
						
		for i in self.defence_priority:
			if i == defence.CITY:
				for j in self.defence_priority[i]:
					if  self.defence_priority[i][j] > max_priority_value:
						max_priority_value = self.defence_priority[i][j]
						max_priority = DEFEND
						max_priority_type = i
						max_priority_target = j
		
		if max_priority == null:
			max_priority = EXPLORE
			max_priority_type = explore.FOW
							
		var best_unit
		if max_priority == ATTACK:
			var max_attack_per_distance = 0
			for i in unassigned_units:
				var attack_per_distance = (pow(unit_profiles[i].attack_score,2)*(i.health/i.health_max))/max(1,Hex.hex_distance(i.hex_pos,max_priority_target.hex_pos))
				if attack_per_distance > max_attack_per_distance:
					max_attack_per_distance = attack_per_distance
					best_unit = i
			self.units_assigned[best_unit] = ATTACK
			self.unit_targets[best_unit] = max_priority_target
			unassigned_units.erase(best_unit)
			self.priorities[max_priority][max_priority_type][max_priority_target] -= total_priority/num_units
		
		if max_priority == DEFEND:
			var max_defence_per_distance = 0
			for i in unassigned_units:
				var defence_per_distance = (pow(unit_profiles[i].defence_score,2)*(i.health/i.health_max))/max(1,Hex.hex_distance(i.hex_pos,max_priority_target.hex_pos))
				if defence_per_distance > max_defence_per_distance:
					max_defence_per_distance = defence_per_distance
					best_unit = i
			self.units_assigned[best_unit] = DEFEND
			self.unit_targets[best_unit] = max_priority_target
			unassigned_units.erase(best_unit)
			self.priorities[max_priority][max_priority_type][max_priority_target] -= total_priority/num_units
			
		if max_priority == EXPLORE and max_priority_type == explore.FOW:
			var max_explore_score = 0
			for i in unassigned_units:
				var explore_score = (pow(unit_profiles[i].explore_score,2)*(i.health/i.health_max))
				if explore_score > max_explore_score:
					max_explore_score = explore_score
					best_unit = i
			self.units_assigned[best_unit] = EXPLORE
			self.unit_targets[best_unit] = null
			unassigned_units.erase(best_unit)
			self.priorities[max_priority][max_priority_type] -= total_priority/num_units
			
		if max_priority == EXPLORE and max_priority_type == explore.CITY:
			var max_explore_score_per_distance = 0
			for i in unassigned_units:
				var explore_score_per_distance = (pow(unit_profiles[i].explore_score,2)*(i.health/i.health_max))/max(1,Hex.hex_distance(i.hex_pos,max_priority_target.hex_pos))
				if explore_score_per_distance > max_explore_score_per_distance:
					max_explore_score_per_distance = explore_score_per_distance
					best_unit = i
			self.units_assigned[best_unit] = EXPLORE
			self.unit_targets[best_unit] = max_priority_target
			unassigned_units.erase(best_unit)
			self.priorities[max_priority][max_priority_type][max_priority_target] -= total_priority/num_units
				
	self.update_assigned_scores()
				
	var assigned_unit_tasks = self.units_assigned.values()
	var explore_units = assigned_unit_tasks.count(EXPLORE)

	for i in self.units_attention_needed:
		if self.units_assigned[i] == EXPLORE:
			if !self.unit_targets.has(i) or self.unit_targets[i] == null:
				self.unit_profiles[i].explore_fow()
				self.explore_priority[explore.FOW] = self.explore_priority[explore.FOW]-(1/explore_units)
			else:
				self.unit_profiles[i].go_to_object(self.unit_targets[i])
				self.explore_priority[explore.CITY][self.unit_targets[i]] = self.explore_priority[explore.CITY][self.unit_targets[i]]-(1/explore_units)
				
		elif self.units_assigned[i] == ATTACK:
			if self.unit_targets[i] != null:
					if self.unit_targets[i] is City:
						print("attack city")
						self.unit_profiles[i].attack_city(self.unit_targets[i])
					elif self.unit_targets[i] is Unit:
						print("attack unit")
						self.unit_profiles[i].attack_unit(self.unit_targets[i])
						
		elif self.units_assigned[i] == DEFEND:
			self.unit_profiles[i].go_to_object(self.unit_targets[i])
			
		elif self.units_assigned[i] == EXPAND:
			if self.unit_targets.has(i) and self.unit_targets[i] != null:
				print("improving city")
				print(self.unit_targets[i])
				self.unit_profiles[i].improve_city(self.unit_targets[i])
			else:
				print("building city")
				self.unit_profiles[i].build_new_city()

	self.update_priorities()
	self.update_build_priorites()

	var total_build_priority = max(0,self.attack_priority[attack.BUILD]) + max(0,self.defence_priority[defence.BUILD]) + max(0,self.explore_priority[explore.BUILD]) + max(0,self.expand_priority[expand.BUILD_CITY]) + max(0,self.expand_priority[expand.BUILD_IMPROVE])
	print("total build: ",total_build_priority)
	var build_unit_priorities = {build.ATTACK:self.attack_priority[attack.BUILD]/total_build_priority,build.DEFEND:self.defence_priority[defence.BUILD]/total_build_priority,
		build.EXPAND_CITY:(self.expand_priority[expand.BUILD_CITY]/total_build_priority),build.EXPAND_IMPROVE:(self.expand_priority[expand.BUILD_IMPROVE]/total_build_priority),
		build.EXPLORE:self.explore_priority[explore.BUILD]/total_build_priority}
	
	
	print("build unit priorities: ",build_unit_priorities)
	var buildings_ready = self.buildings_attention_needed.size()
	for i in self.buildings_attention_needed:
		var highest_priority_unit = 0
		for j in build_unit_priorities.keys():
			if build_unit_priorities[j] > build_unit_priorities[highest_priority_unit]:
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
	self.expand_score = 0
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
	
	print(self.name," scores: a:",self.attack_score,", d:",self.defence_score,", c:",self.city_score,", cd:",self.city_defence_score,", e:",self.explore_score)
	
func update_assigned_scores():
	self.assigned_attack_score = 0
	self.assigned_defence_score = 0
	self.assigned_city_defence_score = 0
	self.assigned_explore_score = 0
	
	for i in self.unit_profiles.values():
		i.update_scores()
		if self.units_assigned.has(i.unit):
			if self.units_assigned[i.unit] == EXPLORE:
				self.assigned_explore_score += i.explore_score
			elif self.units_assigned[i.unit] == ATTACK:
				self.assigned_attack_score += i.attack_score
			elif self.units_assigned[i.unit] == DEFEND:
				self.assigned_defence_score += i.defence_score
				
	for i in self.city_profiles.values():
		i.update_scores()
		self.city_defence_score += i.defence_score + i.unit_defence_score
		self.city_score += i.value_score
	
func update_priorities():
	for i in self.explore_priority.keys():
		if i == explore.CITY:
			self.explore_priority[i] = Dictionary()
		else:
			self.explore_priority[i] = 0
			
	var max_explore_priority = 0
	for i in player_profiles.values():
		for j in i.get_cities():
			self.explore_priority[explore.CITY][j["building"]] = j["last_seen"]/min(self.turn,20)* self.explore_bias
			max_explore_priority = max(max_explore_priority,self.explore_priority[explore.CITY][j["building"]])
				
	self.explore_priority[explore.FOW] = float(self.fow.size())/float(GlobalConfig.map.size())* self.explore_bias
	
	max_explore_priority = max(max_explore_priority,self.explore_priority[explore.FOW])

	var max_expand = 0
	for i in self.expand_priority.keys():
		if i == expand.IMPROVEMENT:
			self.expand_priority[i] = Dictionary()
		else:
			self.expand_priority[i] = 0
			
	for i in self.city_profiles.values():
		self.expand_priority[expand.IMPROVEMENT][i.city] = (1 - (i.value_score/i.potential_value_score) ) * self.expand_bias
		max_expand = max(max_expand,self.expand_priority[expand.IMPROVEMENT][i.city])
		
	self.expand_priority[expand.CITY] = (1 - max_expand)*self.expand_bias
			
	for i in self.attack_priority.keys():
		if i in [attack.CITY,attack.UNIT]:
			self.attack_priority[i] = Dictionary()
		else:
			self.attack_priority[i] = 0
	for i in self.defence_priority.keys():
		if i in [defence.CITY]:
			self.defence_priority[i] = Dictionary()
		else:
			self.defence_priority[i] = 0
		
	self.defence_type = self.defence.BUILD
	
	var area_centre = Vector2(0,0)
	var area_centre_count = 0
	for i in self.area:
		area_centre += i * 3
		area_centre_count += 3
	for i in self.units:
		area_centre += i.hex_pos
		area_centre_count += 1
	area_centre = area_centre/area_centre_count
	area_centre.x = round(area_centre.x)
	area_centre.y = round(area_centre.y)
		
	
	for i in self.player_profiles.values():

		for j in i.get_cities():
			self.attack_priority[attack.CITY][j["building"]] = (self.attack_score/(2*max(1,i.get_city_defence_score(j))))
		
		for j in i.get_units():
			self.attack_priority[attack.UNIT][j["unit"]] = max(j["attack_score"]/max(1,i.aggression),0.5)*(j["attack_score"]/max(1,Hex.hex_distance(area_centre,j["unit_cpy"].hex_pos)))
			
			for k in self.city_profiles.values():
				var unit_influence = j["attack_score"]/(2*max(1,Hex.hex_distance(k.city.hex_pos,j["unit_cpy"].hex_pos)))
				if self.defence_priority[defence.CITY].has(k.city):
					self.defence_priority[defence.CITY][k.city] += unit_influence
				else:
					self.defence_priority[defence.CITY][k.city] = unit_influence
					
		for j in self.city_profiles.values():
			if self.defence_priority[defence.CITY].has(j.city):
				self.defence_priority[defence.CITY][j.city] = (self.defence_priority[defence.CITY][j.city]*j.value_score)/j.defence_score
	
	for i in self.attack_priority[attack.UNIT].keys():
		 self.attack_priority[attack.UNIT][i] = self.attack_priority[attack.UNIT][i] * self.attack_bias
	for i in self.attack_priority[attack.CITY].keys():
		 self.attack_priority[attack.CITY][i] = self.attack_priority[attack.CITY][i] * self.attack_bias
	
	for i in self.defence_priority[defence.CITY].keys():
		 self.defence_priority[defence.CITY][i] = self.defence_priority[defence.CITY][i] * self.defence_bias

	print("explore priority: ", self.explore_priority)
	print("expand priority: ", self.expand_priority)
	print("defence priority: ", self.defence_priority)
	print("attack priority: ", self.attack_priority)
	
	self.priorities[ATTACK] = self.attack_priority
	self.priorities[DEFEND] = self.defence_priority
	self.priorities[EXPLORE] = self.explore_priority
	self.priorities[EXPAND] = self.expand_priority
	
func update_build_priorites():
	var max_explore_priority = 0
	for i in self.explore_priority[explore.CITY]:
			max_explore_priority = max(max_explore_priority,self.explore_priority[explore.CITY][i])
	max_explore_priority = max(max_explore_priority,self.explore_priority[explore.FOW])
	self.explore_priority[explore.BUILD] = (max_explore_priority/max(self.assigned_explore_score,1)) 
	
	var max_attack_priority = 0
	for i in self.attack_priority:
		if i in [attack.CITY,attack.UNIT]:
			for j in self.attack_priority[i]:
				max_attack_priority = max(max_attack_priority,self.attack_priority[i][j])
	self.attack_priority[attack.BUILD] = (max_attack_priority/max(self.assigned_attack_score,1))
	
	var max_defence_priority = 0
	for i in self.defence_priority:
		if i in [defence.CITY]:
			for j in self.defence_priority[i]:
				max_defence_priority = max(max_defence_priority,self.defence_priority[i][j])
	self.defence_priority[defence.BUILD] = (max_defence_priority/max(self.assigned_defence_score,1))
	
	var max_expand_priority = 0
	for i in self.expand_priority:
		if i in [expand.IMPROVEMENT]:
			for j in self.expand_priority[i]:
				max_expand_priority = max(max_expand_priority,self.expand_priority[i][j])
	#max_expand_priority = max(max_expand_priority,self.expand_priority[expand.CITY])
	if self.cities.size() > 0:
		self.expand_priority[expand.BUILD_IMPROVE] = max_expand_priority - ((self.units_assigned.values().count(EXPAND)*max_expand_priority)/self.cities.size())
	else:
		self.expand_priority[expand.BUILD_IMPROVE] = 0
	self.expand_priority[expand.BUILD_CITY] = (self.expand_priority[expand.CITY]*(GlobalConfig.max_cities - self.cities.size())/GlobalConfig.max_cities)
	
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
		if self.unit.attack_range >= Hex.hex_distance(self.unit.hex_pos,city.hex_pos):
			self.unit.attack(city)
		else:
			self.go_to_object(city,self.unit.attack_range)
			
	func attack_unit(enemy):
		if self.unit.attack_range >= Hex.hex_distance(self.unit.hex_pos,enemy.hex_pos):
			self.unit.attack(enemy)
		else:
			self.go_to_object(enemy,self.unit.attack_range)
			
	func explore_fow(dist=5):
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
			#player_center = player_center/player_center_input
			player_center = Vector2(round(player_center.x/player_center_input),round(player_center.y/player_center_input))
			var found = false
			var idx = 0
			while !found and !fow.empty() and OS.get_ticks_msec()-start_time < 750:
				idx += 1
				var search_area = Hex.hex_in_range(dist*idx,player_center)
				if self.player.not_fow.size() > 0.8*search_area.size():
					continue
				search_area.shuffle()
				for i in search_area:
					if i in fow:
						if self.unit.find_path(i):
							found = true
							break
						else:
							fow.erase(i)
			if !found:
				self.explore_bailout()
				print("explore failed")
			print("time taken self.explore : ", OS.get_ticks_msec()-start_time)
			
	func explore_bailout():
		var area = Hex.hex_in_range(4,self.unit.hex_pos)
	
	func builder_select_task():
		if self.unit.can_build_city and self.unit.can_build:
			self.build_new_city()
		elif self.unit.can_build_city:
			self.build_new_city()
		elif self.unit.can_build:
			pass
			
	func build_new_city():
		if self.unit.can_build_city:
				var new_city_location = self.find_new_city_location()
				if new_city_location == null:
					self.unit.explore()
				else:
					if self.unit.hex_pos == new_city_location:
						self.unit.start_build("city")
					else:
						if !self.unit.find_path(new_city_location):
							if GlobalConfig.unit_tiles.has(new_city_location) and GlobalConfig.unit_tiles[new_city_location].get_parent() == self.player:
								SignalManager.make_unit_move(GlobalConfig.unit_tiles[new_city_location],self.unit)
							else:
								var dist = 0
								var found = false
								while dist < Hex.hex_distance(self.unit.hex_pos,new_city_location)-2 and !found:
									dist += 1
									found = self.unit.find_path(Hex.closest_hex_in_range(new_city_location,dist,self.unit.hex_pos))
									
								
	func improve_city(city:City):
		var nearest_tile = null
		var shortest_distance = -1
		print("area: ",city.area)
		for i in city.area:
			if i == city.hex_pos:
				continue
			if city.building_tiles.has(i) and city.building_tiles[i] != null:
				continue
			if GlobalConfig.map.has(i):
				if GlobalConfig.map[i] in GlobalConfig.impasible_biomes or GlobalConfig.map[i] in GlobalConfig.water_biomes:
					continue
			else:
				continue
			var dist = Hex.hex_distance(self.unit.hex_pos,i)
			if shortest_distance == -1 or shortest_distance > dist:
				nearest_tile = i
				shortest_distance = dist
		print("nearest tile: ",nearest_tile)
		print("distance: ",shortest_distance)
		if nearest_tile != null:
			if shortest_distance == 0:
				self.unit.start_build("farm")
			else:
				self.unit.find_path(nearest_tile)
								
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
		var search_area = Array()
		if self.player.cities.size() > 0:
			for i in self.player.cities:
				search_area += Hex.hex_in_range(10,i.hex_pos)
				for j in Hex.hex_in_range(4,i.hex_pos):
					search_area.erase(j)
		else: 
			search_area = player.visible_tiles
			
		for i in search_area:
			if !GlobalConfig.map.has(i):
				continue
			if GlobalConfig.map[i] in GlobalConfig.water_biomes or GlobalConfig.map[i] in GlobalConfig.impasible_biomes:
				continue
			var city_start_area = Hex.hex_in_range(1,i)
			var area_valid = true
			var area_score = {"food":0,"construction":0,"defence":0}
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
	var city: City
	var area: Array
	var buildings: Array
	var building_tiles: Dictionary
	var defence_score: float
	var unit_defence_score: float
	var unit_defence: Array
	var value_score: float
	var potential_value_score: float
	
	func _init(b: City, p):
		self.city = b
		self.buildings = Array()
		self.buildings.append(b)
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
					
		print("city buildings: ", city.buildings)
		for i in self.city.resources_per_turn.keys():
			if i in max_resources_required.keys():
				self.value_score += self.city.resources_per_turn[i] + (self.city.resources_per_turn[i]/max_resources_required[i])
			else:
				self.value_score += self.city.resources_per_turn[i]/2
				
		var potential_resources_per_turn = self.city.resources_per_turn.duplicate()
		self.potential_value_score = self.value_score
		for i in self.city.area:
			if !self.building_tiles.has(i):
				var max_improvement = 0
				var max_resources = Dictionary()
				for j in BuildingFactory.building_templates:
					var temp_resources = Dictionary()
					var total_improvment = 0
					var valid = true
					if !j["is_district"] and valid:
						valid = false
					if j.has("tiles") and !(GlobalConfig.map[i] in j["tiles"]) and valid:
						valid = false
					if j.has("resources") and GlobalConfig.special_resource_tiles.has(i) and valid:
						if !(GlobalConfig.special_resource_tiles[i]["name"] in j["resources"]):
							valid = false
						elif GlobalConfig.special_resource_tiles[i]["name"] in j["resources"]:
							for k in GlobalConfig.special_resource_tiles[i]["improvements"].keys():
								temp_resources[k] = GlobalConfig.special_resource_tiles[i]["improvements"][k]
								total_improvment += GlobalConfig.special_resource_tiles[i]["improvements"][k]
					if valid:
						for k in j["improvements"].keys():
							if temp_resources.has(k):
								temp_resources[k] += j["improvements"][k]
								total_improvment += j["improvements"][k]
							else:
								temp_resources[k] = j["improvements"][k]
								total_improvment += j["improvements"][k]
						if total_improvment > max_improvement:
							max_improvement = total_improvment
							max_resources = temp_resources
				for j in max_resources.keys():
					if potential_resources_per_turn.has(j):
						potential_resources_per_turn[j] += max_resources[j]
					else:
						potential_resources_per_turn[j] = max_resources[j]
							
		for i in potential_resources_per_turn.keys():
			if i in max_resources_required.keys():
				self.potential_value_score += potential_resources_per_turn[i] + (potential_resources_per_turn[i]/max_resources_required[i])
			else:
				self.potential_value_score += potential_resources_per_turn[i]/2
		
		update_unit_defence(self.player.unit_profiles.values())
		
		print("city def: ",self.defence_score+self.unit_defence_score," val: ", self.value_score," pot.val: ",self.potential_value_score)
		
	func add_building(b):
		if b.hex_pos in self.area and !self.building_tiles.has(b.hex_pos):
			self.buildings.append(b)
			self.building_tiles[b.hex_pos] = b
		
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
			if priority == build.EXPLORE:
				self.build_explore_unit()
			elif priority == build.ATTACK:
				self.build_attack_unit()
			elif priority == build.DEFEND:
				self.build_defence_unit()
			elif priority == build.EXPAND_CITY:
				city.start_build("City Builder")
			elif priority == build.EXPAND_IMPROVE:
				city.start_build("Builder")
				
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
	var buildings: Dictionary #[building] = {building,last_seen,building_cpy,updated}
	var cities: Dictionary #[city] = {city,last_seen,city_cpy,updated}
	var units: Dictionary #[unit] = {unit,last_seen,unit_cpy,updated}
	
	var attack_score: float
	var defence_score: float
	var city_defence_score: float
	var aggression: float
	
	func _init(e,p):
		self.enemy = e
		self.player = p
		self.units = Dictionary()
		self.buildings = Dictionary()
		self.cities = Dictionary()
		self.attack_score = 0
		self.defence_score = 0
		self.city_defence_score = 0
		SignalManager.connect("kill_unit",self,"unit_killed")
		SignalManager.connect("kill_building",self,"building_killed")
		SignalManager.connect("unit_moved",self,"unit_moved")
		
	func get_cities():
		return self.cities.values()
		
	func get_units():
		return self.units.values()
	
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
				if building is City:
					cities[building] = buildings[building]
		else:
			buildings[building] = {"building": building, "last_seen": 0, "updated": true, "building_cpy": BuildingFactory.copy_building(building)}
			if building is City:
					cities[building] = buildings[building]
			
			
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
				i["attack_score"] = (i["unit_cpy"].attack*i["unit_cpy"].health)/(max(1,i["last_seen"]) * i["unit_cpy"].health_max)
				attack_score += i["attack_score"]
				i["defence_score"] = (i["unit_cpy"].defence*i["unit_cpy"].health)/(max(1,i["last_seen"]) * i["unit_cpy"].health_max)
				defence_score += i["defence_score"]
		for i in buildings.values():
			self.city_defence_score += self.get_city_defence_score(i)
#			self.city_defence_score += i["building_cpy"].defence
#			if self.cities.has(i["building"]):
#				for j in units.values():
#					var dist = Hex.hex_distance(j["unit_cpy"].hex_pos,i["building_cpy"].hex_pos)
#					if dist < 5:
#						self.city_defence_score += j["unit_cpy"].defence/(max(1,0.5*dist)*max(1,0.5*j["last_seen"]))
		print(self.enemy.get_name()," profile atck: ",self.attack_score, " def: ", self.defence_score, " city_def: ", self.city_defence_score, " agr: ", self.aggression)
			
	func get_city_defence_score(city):
		var city_defence = city["building_cpy"].defence
		if self.cities.has(city["building"]):
			for i in units.values():
				var dist = Hex.hex_distance(i["unit_cpy"].hex_pos,city["building_cpy"].hex_pos)
				if dist < 5:
					self.city_defence_score += i["unit_cpy"].defence/(max(1,0.5*dist)*max(1,0.5*i["last_seen"]))
		return city_defence
	
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
			self.buildings.erase(building)
		if self.cities.has(building):
			self.cities.erase(building)
			
	func unit_moved(unit,from,to):
		if unit in self.units and to in self.player.visible_tiles:
			self.update_unit(unit)
		
			
		
	
	
	
