extends GameObject

class_name Unit

var speed: int = 300
var move_range: int
var can_build: bool
var can_build_city: bool
var can_trade: bool 
var can_move_water: bool

var moves: Array = Array()
var build_turns_left: int
var build_curr: String
var moves_left: int setget set_moves_left
var explore: bool
var recover: bool

#### modes ####
const DEFAULT = 0
const MOVE = 1
const MOVE_WAIT = 2
const ATTACK = 3
const ATTACK_MOVE = 4
const BUILD = 5

func _init():
	can_move_water = false
	selected = false
	explore = false
	recover = false
	build_turns_left = 0
	build_curr = ""
	mode = DEFAULT
	pass
	
func set_moves_left(m):
	moves_left = m
	SignalManager.moves_left_change(self,m)

func set_hex_pos(h):
	if hex_pos != null:
		GlobalConfig.unit_tiles.erase(hex_pos)
	GlobalConfig.unit_tiles[h] = self
	hex_pos = h
	
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
		
class a_star_node:
	var distance_heuristic
	var distance_traveled
	var hex_pos
	var hex_effort
	var parent
	var start
	var goal
	var previous
	var children
	
	func _init(h,t,hex,parent=null):
		distance_heuristic = h
		distance_traveled = t
		hex_pos = hex
		hex_effort = GlobalConfig.biome_moves[GlobalConfig.map[hex_pos]]
		self.parent = parent
		self.previous = Array()
		if parent != null:
			self.previous += self.parent.previous
			self.previous.append(self.parent.hex_pos)
		
	static func sort_nodes(a,b):
		if (a.distance_heuristic+a.distance_traveled) < (b.distance_heuristic+b.distance_traveled):
			return true
		elif(a.distance_heuristic+a.distance_traveled) == (b.distance_heuristic+b.distance_traveled):
			if(a.distance_heuristic < b.distance_heuristic):
				return true
			elif(a.distance_heuristic == b.distance_heuristic):
				pass
		return false
		
	func start_to_node_distance(node):
		var curr_node = node
		var distance = 0
		while curr_node.parent!=null:
			distance += curr_node.parent.hex_effort
			curr_node = curr_node.parent
		return distance
	

func heuristic_distance(destination, from, start = null):
	var heuristic = Hex.hex_distance(destination,from)*25
	if start != null: #heuristic tie break from http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html#S1
		var start_point = Hex.hex_to_point(start)/32
		var destination_point = Hex.hex_to_point(destination)/32
		var from_point = Hex.hex_to_point(from)/32
		
		var dx1 = from_point.x - destination_point.x
		var dy1 = from_point.y - destination_point.y
		var dx2 = start_point.x - destination_point.x
		var dy2 = start_point.y - destination_point.y
		var cross = abs(dx1*dy2 - dx2*dy1)
		heuristic += cross*0.001
	return  heuristic
	
#a* pathfinding algorithm
func find_path(destination,debug = false):
	var start = a_star_node.new(heuristic_distance(destination,self.hex_pos,self.hex_pos),0,self.hex_pos)
	var path_found = false
	var nodes = Array()
	var visited_nodes = Array()
	nodes.push_back(start)
	if debug:
		print("start: "+ str(hex_pos))
		print("destination: "  + str(destination))
		
	var idx = 0
	while !path_found and !nodes.empty() and idx < 2000:
		idx += 1
		nodes.sort_custom(a_star_node,"sort_nodes")
		if debug:
			print("step: " + str(idx))
			for i in nodes:
				print("node: " + str(i.hex_pos) + " h:" + str(i.distance_heuristic) + " d:" + str(i.distance_traveled) )
			
		var current_node = nodes.pop_front()
		if debug:
			print("curr_node: " + str(current_node.hex_pos) )
			
		if current_node.hex_pos == destination:
			mode = MOVE ###################################################################
			var path = Array()
			while current_node:
				path.push_front(current_node)
				current_node = current_node.parent 
			path_found = true
			self.moves = path
			return true
		else:
			var node_neighbors = Hex.hex_in_range(1,current_node.hex_pos)
			if debug:
				print("neighbors: " + str(node_neighbors))
			for i in node_neighbors:
				if (GlobalConfig.map[i] in GlobalConfig.impasible_biomes):
					#print("mountain")
					continue
				if (GlobalConfig.map[i] in GlobalConfig.water_biomes) and (not can_move_water):
					#print("water")
					continue
				if (i in current_node.previous):
					continue
				if (i in GlobalConfig.unit_tiles.keys()):
					continue
					
				nodes.push_front(a_star_node.new(heuristic_distance(destination,i,self.hex_pos),current_node.distance_traveled + (current_node.hex_effort*5),i,current_node))
	print("failed")
	return false 
	
func attack(enemy):
	mode = ATTACK
	if self.moves_left > 0:
		if enemy.hex_pos in Hex.hex_in_range(self.attack_range,self.hex_pos):
			print("atk rng: " + str(attack_range))
			if self.attack_range > 1:
				var damage = rand_range(0.8*self.attack,self.attack)
				damage = damage * (self.moves_left+move_range)/(2*move_range)
				damage -= rand_range(0.1*enemy.defence,0.25*enemy.defence)
				damage = max(damage,0)
				enemy.health = enemy.health - damage
			else:
				var damage = rand_range(0.8*self.attack,self.attack)
				damage = damage * (self.moves_left+move_range)/(2*move_range)
				damage -= rand_range(0.1*enemy.defence,0.25*enemy.defence)
				damage = max(damage,0)
				print("damage: " + str(damage))
				
				var enemy_damage = rand_range(0.8*enemy.defence,enemy.defence)
				enemy_damage = enemy_damage * (enemy.self.moves_left+enemy.move_range)/(2*enemy.move_range)
				enemy_damage -= rand_range(0.2*self.defence,0.4*self.defence)
				enemy_damage = max(enemy_damage,0)
				print("en damage: " + str(enemy_damage))
				enemy.health = enemy.health - damage
				self.health = self.health - enemy_damage
			
			if self.health < 0:
				self.kill()
			if enemy.health < 0:
				enemy.kill()
			
func kill():
	self.visible = false
	self.get_parent().kill(self)
	self.queue_free()
	
func can_build(building) -> bool:
	if self.hex_pos in GlobalConfig.building_tiles.keys():
		return false
	if BuildingFactory.building_templates_by_name[building]["is_city"] and self.can_build_city:
		return true
	elif BuildingFactory.building_templates_by_name[building]["is_district"] and self.can_build:
		return true
	return false
	
func start_build(building):
	if moves_left > 0:
		if BuildingFactory.building_templates_by_name.has(building):
			self.build_turns_left = BuildingFactory.building_templates_by_name[building]["build_turns"]
			if build_turns_left == 0:
				build_turns_left = -1
				var new_building = BuildingFactory.build_building(building,hex_pos,self.get_parent())
				self.get_parent().new_building(new_building)
				mode = DEFAULT
			else:
				self.build_curr = building
				self.mode = BUILD
			
			self.moves_left = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mode == MOVE or (mode == MOVE_WAIT and !self.get_parent().is_turn):
		if self.position == Hex.hex_to_point(self.hex_pos):
			if !moves.empty() and self.moves_left > 0:
				while moves.front().hex_pos == self.hex_pos:
					moves.pop_front()
				var move = moves.pop_front()
				if GlobalConfig.unit_tiles.has(move.hex_pos) and GlobalConfig.unit_tiles[move.hex_pos] != self:
					moves.clear()
					mode = DEFAULT
				else:
					self.hex_pos = move.hex_pos
					self.moves_left -= move.hex_effort
					
			elif self.moves_left <= 0:
				self.mode = MOVE_WAIT
				
		else:
			var diff = Hex.hex_to_point(self.hex_pos) - self.position
			var abs_distance = sqrt(pow(diff.x,2)+pow(diff.y,2))
			var velocity = 0
			if delta > 0:
				velocity = abs_distance / (speed * delta)
			else:
				velocity = abs_distance / (speed * 0.001)
			var move_vector
			
			if velocity <= 1:
				move_vector = diff
				if self.moves_left <= 0:
					self.moves_left = 0
					if !moves.empty():
						mode = MOVE_WAIT
					else:
						mode = DEFAULT
				
			else:
				move_vector =  diff / velocity
				
			var new_pos = self.position+move_vector
			self.position = new_pos
