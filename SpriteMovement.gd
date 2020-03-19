extends Sprite

var hex = load("res://HexOperations.gd").Hex

var speed = 150
var moves = Array()
var selected = true
var hex_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	hex_pos = Vector2(int(rand_range(0,5)),int(rand_range(0,5)))
	self.position = hex.hex_to_point(hex.hex_round_axial(hex_pos))
	pass

func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		print("sprite: "+str(event.position))
		self.on_click(event.position)

func on_click(click_position):
	var hex_coord = hex.point_to_hex(click_position)
	print("global")
	print (get_global_mouse_position())
	var hex_centre = hex.hex_to_point(hex_coord)
	print("hex")
	print(hex_coord)
	print (hex_centre)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
