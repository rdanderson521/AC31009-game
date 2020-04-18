extends GameObject

class_name Unit

var speed: int = 300
var type: String
var move_range: int
var health_max: int
var attack: int
var attack_range: int
var defence: int
var can_build: bool
var can_build_city: bool
var can_trade: bool 
var can_move_water: bool
var texture: String setget set_texture

var moves: Array = Array()
var build_turns_left: int
var build_curr: String
var moves_left: int
var health: float
var explore: bool
var recover: bool
var selected: bool
var hex_pos: Vector2
var mode: int

#### modes ####
const DEFAULT = 0
const MOVE = 1
const MOVE_WAIT = 2
const ATTACK = 3
const ATTACK_MOVE = 4
const BUILD = 5

func _init():
	#SignalManager.connect("unit_move_btn_click",self,"move_test")
	can_move_water = false
	selected = false
	explore = false
	recover = false
	build_turns_left = -1
	mode = DEFAULT
	pass
	
func move_test():
	self.find_path(hex_pos+Vector2(3,3))
	
func set_texture(texture):
	$Area2D/CollisionPolygon2D/Sprite.texture = load(texture)
	pass
	
func turn_start() -> bool:
	if mode == BUILD:
		if build_turns_left > 0:
			build_turns_left -=1
			return false
		elif build_turns_left == 0:
			build_turns_left = -1
			BuildingFactory.build(build_curr,hex_pos) ########## build func still needs made #########
			mode = DEFAULT
		
	moves_left = move_range

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
			print("previous: " + str(previous) )
		
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
		

func rand_move():
	self.hex_pos = Vector2(int(rand_range(0,5)),int(rand_range(0,5)))
	self.position = Hex.hex_to_point(Hex.hex_round_axial(hex_pos))
	
	
	

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
	var start = a_star_node.new(heuristic_distance(destination,hex_pos,self.hex_pos),0,hex_pos)
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
					
#				var node_found = false
#				for j in nodes:
#					if j.hex_pos == i:
#						if j.distance_traveled > current_node.distance_traveled + (current_node.hex_effort*5):
#							nodes.push_front(a_star_node.new(j.distance_heuristic,current_node.distance_traveled + (current_node.hex_effort*5),i,current_node))
#							nodes.erase(j)
#							print("node replaced")
#							node_found = true
#							break
#						else:
#							node_found = true
#							break
#				if node_found:
#					continue
							
				nodes.push_front(a_star_node.new(heuristic_distance(destination,i,self.hex_pos),current_node.distance_traveled + (current_node.hex_effort*5),i,current_node))
	print("failed")
	return false 
	
	
func attack(enemy):
	mode = ATTACK
	if enemy.hex_pos in Hex.hex_in_range(self.attack_range,self.hex_pos):
		if self.attack_range > 1:
			var damage = rand_range(0.8*self.attack,self.attack)
			damage -= rand_range(0.1*enemy.defence,0.25*enemy.defence)
			damage = max(damage,0)
			enemy.health -= damage
		else:
			var damage = rand_range(0.8*self.attack,self.attack)
			damage -= rand_range(0.1*enemy.defence,0.25*enemy.defence)
			damage = max(damage,0)
			
			var enemy_damage = rand_range(0.8*enemy.defence,enemy.defence)
			enemy_damage -= rand_range(0.2*self.defence,0.4*self.defence)
			enemy_damage = max(enemy_damage,0)
			
			enemy.health -= damage
			self.health -= enemy_damage
		
		if self.health < 0:
			self.kill()
		if enemy.health < 0:
			enemy.kill()
			
func kill():
	self.visible = false
	self.get_parent().kill(self)
	self.queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mode == MOVE or (mode == MOVE_WAIT and !self.get_parent().is_turn):
		if !moves.empty() and moves_left > 0:
			var diff = Hex.hex_to_point(moves.front().hex_pos) - self.position
			print("move diff: " + str(diff))
			var abs_distance = sqrt(pow(diff.x,2)+pow(diff.y,2))
			var velocity = 0
			if delta > 0:
				velocity = abs_distance / (speed * delta)
			else:
				velocity = abs_distance / (speed * 0.001)
			var move_vector
			
			if velocity <= 1:
				move_vector = diff
				var move = moves.pop_front()
				hex_pos = move.hex_pos
				moves_left -= move.hex_effort
				if moves_left <= 0:
					moves_left = 0
					if !moves.empty():
						mode = MOVE_WAIT
					else:
						mode = DEFAULT
			else:
				move_vector =  diff / velocity
				
			var new_pos = self.position+move_vector
			self.position = new_pos
