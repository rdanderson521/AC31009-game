extends Player

class_name AI

var state: int
var unit_profiles: Dictionary

const EXPLORE = 0
const BUILD = 1
const ATTACK = 2
const READY_ATTACK = 3

func _init(start_hex:Vector2).(start_hex,true):
	self.unit_vis_range = 5
	self.building_vis_range = 7
	self.state = EXPLORE
	self.unit_profiles = Dictionary()
	pass
		
func turn_start():
	is_turn = true
	self.turn += 1
	
	units_attention_needed.clear()
	buildings_attention_needed.clear()
	
	if !units.empty():
		for i in self.units:
			unit_profiles[i].select_task()
			if i.turn_start():
				#units_attention_needed.push_back(i)
				pass
					
	if !buildings.empty():
		for i in self.buildings:
			if i.turn_start():
				buildings_attention_needed.push_back(i)
				
				
	self.turn_end()

func turn_end():
	if is_turn:
		is_turn = false
		selected_object = null
		SignalManager.player_turn_ended(self)
		
func building_decisions():
	for i in self.buildings_attention_needed:
		var building_resources = i.resources_per_turn
		
func new_unit(unit:Unit):
	self.add_child(unit)
	self.units.append(unit)
	self.unit_profiles[unit] = UnitProfile.new(unit,self)
	self.visible_tiles += Hex.hex_in_range(self.unit_vis_range,unit.hex_pos)
	self.reset_visible()
	if unit.turn_start():
		self.units_attention_needed.append(unit)

class UnitProfile:
	var player: Player
	var is_own: bool
	var unit: Unit
	var attack_score: float
	var defence_score: float
	var explore_score: float
	var is_builder: bool
	
	func _init(u: Unit, p: Player):
		self.unit = u
		self.player = p
		
		if self.unit.can_build or self.unit.can_build_city:
			self.is_builder = true
		else:
			self.is_builder = false
			
		self.update_scores()
		
	func update_scores():
		self.attack_score = ((self.unit.attack * self.unit.attack_range * 0.75) * (self.unit.health / self.unit.health_max))
		self.defence_score = (self.unit.defence * (self.unit.health / self.unit.health_max))
		self.explore_score = (self.unit.move_range * (self.unit.health / self.unit.health_max))
		
	func select_task():
		self.update_scores()
		if self.is_builder and self.unit.can_build_city:
			print("is builder")
			var new_city_location = self.find_new_city_location()
			if new_city_location == null:
				#self.explore()
				print("explore")
			else:
				print("build city")
				if self.unit.hex_pos == new_city_location:
					print("build")
					self.unit.start_build("city")
				else:
					print("got to build")
					self.unit.find_path(new_city_location)
			
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
			#print(city_locations)
			return city_locations.back()["area"]
		return null
			
	
	
		
		
		
		
		
		
		
		
