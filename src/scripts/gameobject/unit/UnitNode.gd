extends GameObject

class_name Unit

var speed: int = 10
var type: String
var move_range: int
var health_max: int
var damage: int
var damage_range: int
var can_build: bool
var can_build_city: bool
var can_trade: bool 
var texture: String setget set_texture

var moves: Array = Array()
var build_turns_left: int
var build_curr: String
var moves_left: int
var health: float
var explore: bool
var recover: bool
var selected: bool = false #setget set_selected
var hex_pos: Vector2


func _init():
	pass
	
func set_texture(texture):
	$Area2D/CollisionPolygon2D/Sprite.texture = load(texture)
	pass
	
func turn_start() -> bool:
	if build_turns_left > 0:
		build_turns_left -=1
		#moves_left = -1
		return false
	elif build_turns_left == 0:
		build_turns_left = -1
		BuildingFactory.build(build_curr,hex_pos) ########## build func still needs made #########
		
	moves_left = move_range
	if !moves.empty():
		return false
	if explore:
		return false
	if recover:
		health += (rand_range(0.05,0.15)*health_max)
		if health >= health_max-(0.05*health_max):
			health = health_max
			recover = false
	return true
		
		
#signal is_selected(val)
#
#func set_selected(selected_val):
#	emit_signal("is_selected",selected_val)
#	selected = selected_val

class a_star_node:
	var distance_heuristic
	var distance_traveled
	var hex_pos
	var parent
	var child
	var start
	var goal
	
	func _init(h,t,hex,parent=null):
		distance_heuristic = h
		distance_traveled = t
		hex_pos = hex
		self.parent = parent
		
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
			distance += 2
			curr_node = curr_node.parent
		return distance
		

func rand_move():
	self.hex_pos = Vector2(int(rand_range(0,5)),int(rand_range(0,5)))
	self.position = Hex.hex_to_point(Hex.hex_round_axial(hex_pos))
	
func heuristic_distance(destination, from, start = null):
	var heuristic = Hex.hex_distance(destination,from)*5
	if start != null: #heuristic tie break from http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html#S1
		var start_point = Hex.hex_to_point(start)
		var destination_point = Hex.hex_to_point(destination)
		var from_point = Hex.hex_to_point(from)
		
		var dx1 = from_point.x - destination_point.x
		var dy1 = from_point.y - destination_point.y
		var dx2 = start_point.x - destination_point.x
		var dy2 = start_point.y - destination_point.y
		var cross = abs(dx1*dy2 - dx2*dy1)
		heuristic += cross*0.1
	
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
	while !path_found and !nodes.empty():
		nodes.sort_custom(a_star_node,"sort_nodes")
		var current_node = nodes.pop_front()
		if debug:
			print("curr_node: " + str(current_node.hex_pos) )
		if current_node.hex_pos == destination:
			var path = Array()
			while current_node:
				path.push_front(current_node.hex_pos)
				current_node = current_node.parent 
			path_found = true
			self.moves = path
			return true
		else:
			var node_neighbors = Hex.hex_in_range(1,current_node.hex_pos)
			if debug:
				print("neighbors: " + str(node_neighbors))
			for i in node_neighbors:
				nodes.push_back(a_star_node.new(heuristic_distance(destination,i,self.hex_pos),current_node.distance_traveled + 1,i,current_node))
	return false 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !moves.empty():
		#print("moving")
		var diff = moves.front() - hex_pos
		var abs_distance = sqrt(pow(diff.x,2)+pow(diff.y,2))
		var velocity = 0
		if delta > 0:
			velocity = abs_distance / (speed * delta)
		else:
			velocity = abs_distance / (speed * 0.001)
		#print("vel: " + str(velocity))
		var move_vector
		if velocity <= 1:
			moves.pop_front()
			move_vector = diff
		else:
			move_vector =  diff / velocity
		#print("move: " + str(move_vector))
		hex_pos = hex_pos + move_vector
		var new_pos = Hex.hex_to_point(hex_pos)
		self.position = new_pos












#signal sprite_clicked(sprite)
#
#func _on_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton \
#	and event.button_index == BUTTON_LEFT \
#	and event.is_pressed():
#		self.selected = true
#		emit_signal("sprite_clicked",self)
#
#func _on_tilemap_clicked(click_hex_pos):
#	if selected:
#		if Hex.hex_distance(click_hex_pos, hex_pos) <= move_range:
#			find_path(click_hex_pos)
#		self.selected = false
#