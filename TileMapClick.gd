extends TileMap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var hex = load("res://HexOperations.gd").Hex

var click_position
var draw_list = Array()

func _ready():
	self.cell_custom_transform.y.y = sqrt(3)*(self.cell_size.x/2)
	self.cell_custom_transform.x.y = (sqrt(3)*(self.cell_size.x/2))/2
	self.cell_size.y = sqrt(3)*(self.cell_size.x/2)


func _draw():
	for i in draw_list:
		draw_polyline(i,Color.red)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	pass
