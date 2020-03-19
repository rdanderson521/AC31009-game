extends Sprite

var hex = load("res://HexOperations.gd").Hex

var speed = 150
var moves = Array()
var selected = true
var hex_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	self.hex_pos = Vector2(int(rand_range(0,5)),int(rand_range(0,5)))
	self.position = hex.hex_to_point(hex.hex_round_axial(hex_pos))

func rand_move():
	self.hex_pos = Vector2(int(rand_range(0,5)),int(rand_range(0,5)))
	self.position = hex.hex_to_point(hex.hex_round_axial(hex_pos))
	
func find_path(destination):
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
