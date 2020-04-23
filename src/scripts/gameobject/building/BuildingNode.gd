extends GameObject

class_name Building

var is_city: bool
var is_district: bool
var improvements: Dictionary
var area: Array
var resources_per_turn: Dictionary
var build_curr: String
var build_resources_left: Dictionary

const DEFAULT = 0
const ATTACK = 3
const BUILD = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_parent().area += self.area
	print(self.get_parent())
	self.resources_per_turn = {"food":3}

func set_hex_pos(h):
	hex_pos = h
	GlobalConfig.building_tiles[h] = self
	
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
			var new_unit = UnitFactory.build_unit(build_curr,hex_pos,self.get_parent())
			self.get_parent().new_unit(new_unit)
			mode = DEFAULT
		else:
			return false
			

	return true
	
func turn_end():
	pass

func can_build(building) -> bool:
	if self.mode == BUILD:
		return false
	if UnitFactory.unit_templates_by_name.keys().has(building):
		var cost = UnitFactory.unit_templates_by_name[building]["cost"]
		for i in cost.keys():
			if !i in self.resources_per_turn.keys():
				return false
			elif resources_per_turn[i] <= 0:
				return false
		return true
#	elif BuildingFactory.building_templates_by_name[building]["is_upgrade"]:
#		return true
	return false

func start_build(building_name:String):
	if self.can_build(building_name):
		if BuildingFactory.building_templates_by_name.has(building_name):
			pass
#			self.build_turns_left = BuildingFactory.building_templates_by_name[building_name]["build_turns"]
#			if build_turns_left == 0:
#				build_turns_left = -1
#				var new_building = BuildingFactory.build_building(building_name,hex_pos,self.get_parent())
#				self.get_parent().new_building(new_building)
#				mode = DEFAULT
#			else:
#				self.build_curr = building_name
#				self.mode = BUILD
		elif UnitFactory.unit_templates_by_name.has(building_name):
			print("building start unit")
			self.build_resources_left = UnitFactory.unit_templates_by_name[building_name]["cost"].duplicate()
			self.build_curr = building_name
			self.mode = BUILD
	else:
		return false
			
			
func _draw():
	print("draw")
	if is_city:
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
			
	
