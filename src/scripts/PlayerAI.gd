extends Player

class_name AI

var state: int
var unit_profiles: Dictionary
var city_profiles: Dictionary

var attack_score: float
var defence_score: float
var city_score: float
var city_defence_score: float

var attack_priority: float
var defence_priority: float
var expand_priority: float
var explore_priority: float

var attack_bias: float
var defence_bias: float
var expand_bias: float

const EXPLORE = 0
const BUILD = 1
const ATTACK = 2
const READY_ATTACK = 3

func _init(start_hex:Vector2).(start_hex,true):
	self.unit_vis_range = 4
	self.building_vis_range = 5
	
	self.attack_score = 0
	self.defence_score = 0
	self.city_score = 0
	
	self.attack_priority = rand_range(0.5,2)
	self.defence_priority = rand_range(0.5,2)
	self.expand_priority = rand_range(0.5,2)
	
	self.state = EXPLORE
	self.unit_profiles = Dictionary()
	SignalManager.connect("move_wait_finished",self,"unit_turn_finished")
		
func turn_start():
	is_turn = true
	self.turn += 1
	
	units_attention_needed.clear()
	buildings_attention_needed.clear()
	
	if !units.empty():
		for i in self.units:
			unit_profiles[i].update_scores()
			if i.turn_start():
				units_attention_needed.push_back(unit_profiles[i])
					
	if !buildings.empty():
		for i in self.buildings:
			city_profiles[i].update_scores()
			if i.turn_start():
				buildings_attention_needed.push_back(city_profiles[i])
			
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
	if unit in self.units_attention_needed:
		self.units_attention_needed.erase(unit)
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
		self.buildings_attention_needed.append(building)
		
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
		print(i.unit.type)
		i.select_task()
		
		
	self.turn_end()
	
func update_scores():
	self.attack_score = 0
	self.defence_score = 0
	self.city_score = 0
	self.city_defence_score = 0
	for i in self.unit_profiles.values():
		i.update_scores()
		self.attack_score += i.attack_score
		self.defence_score += i.defence_score
		
	for i in self.city_profiles.values():
		i.update_scores()
		self.city_defence_score += i.defence_score + i.unit_defence_score
		self.city_score += i.value_score
	print(self.name,": ",self.attack_score,", ",self.defence_score,", ",self.city_score,", ",self.city_defence_score)





class UnitProfile:
	var player: Player
	var is_own: bool
	var unit: Unit
	var attack_score: float
	var defence_score: float
	var explore_score: float
	var is_builder: bool
	var need_to_move: bool
	
	
	func _init(u: Unit, p: Player):
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
	var player: Player
	var is_own: bool
	var city: Building
	var area: Array
	var buildings: Array
	var defence_score: float
	var unit_defence_score: float
	var unit_defence: Array
	var value_score: float
	
	func _init(b: Building, p: Player):
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
					
			

