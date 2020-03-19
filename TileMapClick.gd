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

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click(event.position)

func on_click(click_position):
	pass
	#var camera = self.get_child(0)
	#var global_click_position =  (camera.get_camera_position() + (( click_position - camera.get_viewport().get_visible_rect().size/2) * camera.scale * camera.get_zoom()))

	#var hex_coord = hex.point_to_hex(global_click_position)
	#hex.hex_in_range(1,hex_coord)
	#hex.hex_in_range(1,hex_coord)
	#set_cellv(hex_coord,-1)
	
	#var hex_centre = hex.hex_to_point(hex_coord)
	#print (hex_centre)
	#var points = Array()
	#points.push_back(Vector2(hex_centre.x-8,hex_centre.y-14))
	#points.push_back(Vector2(hex_centre.x+8,hex_centre.y-14))
	#points.push_back(Vector2(hex_centre.x+16,hex_centre.y))
	#points.push_back(Vector2(hex_centre.x+8,hex_centre.y+14))
	#points.push_back(Vector2(hex_centre.x-8,hex_centre.y+14))
	#points.push_back(Vector2(hex_centre.x-16,hex_centre.y))
	#points.push_back(Vector2(hex_centre.x-8,hex_centre.y-14))
	#draw_list.push_back(points)
	#print (draw_list.size())
	

func _draw():
	for i in draw_list:
		draw_polyline(i,Color.red)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	pass
