extends Sprite

var hex = load("res://HexOperations.gd").Hex

class a_star_node:
	var distance_heuristic
	var distance_traveled
	var hex_pos
	var parent
	var child
	
	func _init(h,t,hex,parent=null):
		distance_heuristic = h
		distance_traveled = t
		hex_pos = hex
		self.parent = parent
		
	static func sort_descending(a,b):
		if (a.distance_heuristic+a.distance_traveled) < (b.distance_heuristic+b.distance_traveled):
			return true
		return false
		
	func start_to_node_distance(node):
		var curr_node = node
		var distance = 0
		while curr_node.parent!=null:
			distance += 2
			curr_node = curr_node.parent
		return distance
		

var speed = 15
var moves = Array()
var selected = true
var hex_pos
var move_range = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	self.hex_pos = Vector2(int(rand_range(0,5)),int(rand_range(0,5)))
	self.position = hex.hex_to_point(hex.hex_round_axial(hex_pos))

func rand_move():
	self.hex_pos = Vector2(int(rand_range(0,5)),int(rand_range(0,5)))
	self.position = hex.hex_to_point(hex.hex_round_axial(hex_pos))
	
func heuristic_distance(destination, from):
	return hex.hex_distance(destination,from)*5
	
#a* pathfinding algorithm	
func find_path(destination,debug = true):
	var start = a_star_node.new(heuristic_distance(destination,hex_pos),0,hex_pos)
	var path_found = false
	var nodes = Array()
	var visited_nodes = Array()
	nodes.push_back(start)
	if debug:
		print("start: "+ str(hex_pos))
		print("destination: "  + str(destination))
	while !path_found and !nodes.empty():
		nodes.sort_custom(a_star_node,"sort_descending")
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
		else:
			var node_neighbors = hex.hex_in_range(1,current_node.hex_pos)
			print("neighbors: " + str(node_neighbors))
			for i in node_neighbors:
				nodes.push_back(a_star_node.new(heuristic_distance(destination,i),current_node.distance_traveled + 1,i,current_node))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !moves.empty():
		#print("moving")
		var diff = moves.front() - hex_pos
		var abs_distance = sqrt(pow(diff.x,2)+pow(diff.y,2))
		var velocity = abs_distance / (speed * delta)
		#print("vel: " + str(velocity))
		var move_vector
		if velocity <= 1:
			moves.pop_front()
			move_vector = diff
		else:
			move_vector =  diff / velocity
		#print("move: " + str(move_vector))
		hex_pos = hex_pos + move_vector
		var new_pos = hex.hex_to_point(hex_pos)
		self.position = new_pos
		
		pass
		#var velocity = moves.pop_front() - hex_pos
		
		#if velocity * delta <= Vector2(speed,speed):
		#	pass
		#else:
			#velocity = velocity * (Vector2(speed,speed)*delta)
		#	moves.pop_front()
		#	pass
		#hex_pos = hex_pos + velocity#delta)
		#var new_pos = hex.hex_to_point(hex_pos)
		#self.position = new_pos
	pass
