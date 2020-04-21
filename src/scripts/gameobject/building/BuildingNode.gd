extends GameObject

class_name Building

var is_city: bool
var is_district: bool
var improvements: Dictionary
var area: Array
var food_per_turn: float


# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_parent().area += self.area
	print(self.get_parent())
	self.food_per_turn = 3
	#update()

func set_hex_pos(h):
	hex_pos = h
	GlobalConfig.building_tiles[h] = self
	
func turn_start() -> bool:
	if mode == BUILD:
		if build_turns_left > 0:
			build_turns_left -=1
			return false
		elif build_turns_left == 0:
			build_turns_left = -1
			var new_building = BuildingFactory.build_building(build_curr,hex_pos,self.get_parent())
			self.get_parent().new_building(new_building)
			mode = DEFAULT
		
	self.moves_left = move_range

	if mode in [MOVE_WAIT,ATTACK_MOVE]:
		return false
	if explore:
		return false
	if recover:
		health += (rand_range(0.05,0.15)*health_max)
		if health >= health_max-(0.05*health_max):
			health = health_max
			recover = false
	return true
	
func turn_end():
	if self.mode == MOVE_WAIT and self.moves_left > 0:
		self.mode = MOVE

func can_build(building) -> bool:
	if self.hex_pos in GlobalConfig.building_tiles.keys():
		return false
	if BuildingFactory.building_templates_by_name[building]["is_city"] and self.can_build_city:
		return true
	elif BuildingFactory.building_templates_by_name[building]["is_district"] and self.can_build:
		return true
	return false

func start_build(building_name:String):
	if moves_left > 0:
		if BuildingFactory.building_templates_by_name.has(building_name):
			self.build_turns_left = BuildingFactory.building_templates_by_name[building_name]["build_turns"]
			if build_turns_left == 0:
				build_turns_left = -1
				var new_building = BuildingFactory.build_building(building_name,hex_pos,self.get_parent())
				self.get_parent().new_building(new_building)
				mode = DEFAULT
			else:
				self.build_curr = building_name
				self.mode = BUILD
			
			self.moves_left = 0

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
			
	
