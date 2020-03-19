extends Sprite

var hex = load("res://HexOperations.gd").Hex


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	self.position = hex.hex_to_point(hex.hex_round_axial(Vector2(rand_range(0,5),rand_range(0,5))))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
