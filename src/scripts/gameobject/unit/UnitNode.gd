extends GameObject

class_name Unit


var speed = 10
var type
var move_range
var health_max
var damage
var damage_range
var can_build
var can_build_city
var can_trade
var texture setget set_texture

var moves = Array()
var moves_left
var health
var selected = false setget set_selected
var hex_pos 

#func init(name, health, move_range, damage, damage_range, can_build, can_build_city, texture, hex_pos):
#	print("sprite init")
#	self.type = name
#	self.health_max = health
#	self.health = health
#	self.move_range = move_range
#	self.moves_left = move_range
#	self.damage = damage
#	self.damage_range = damage_range
#	self.can_build = can_build
#	self.can_build_city = can_build_city
#	$Area2D/CollisionPolygon2D/Sprite.texture = load("res://"+texture)
#	self.hex_pos = hex_pos
#	self.position = Hex.hex_to_point(hex_pos)
#	moves = Array()
#	selected = false
#
#	self.connect("is_selected",get_tree().get_root().find_node("SpriteGui"),"_on_Sprite_is_selected")
#	self.connect("sprite_clicked",get_tree().get_root().find_node("SpriteGui"),"_on_Sprite_sprite_clicked")
	

func _init():
	#print("newSprite")
	pass
	
func set_texture(texture):
	$Area2D/CollisionPolygon2D/Sprite.texture = load(texture)
	pass

signal is_selected(val)

func set_selected(selected_val):
	emit_signal("is_selected",selected_val)
	selected = selected_val

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
		

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#self.hex_pos = Vector2(int(rand_range(0,5)),int(rand_range(0,5)))
	#self.position = Hex.hex_to_point(Hex.hex_round_axial(hex_pos))

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
		
signal sprite_clicked(sprite)

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.selected = true
		emit_signal("sprite_clicked",self)

func _on_tilemap_clicked(click_hex_pos):
	if selected:
		if Hex.hex_distance(click_hex_pos, hex_pos) <= move_range:
			find_path(click_hex_pos)
		self.selected = false
		
