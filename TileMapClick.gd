extends "res://TileMapGenerator.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		self.on_click(event.position)

func on_click(click_position):
	print("Click")
	print(click_position)
	var camera = self.get_child(0)
	print(camera.get_viewport_rect().size/2)
	print(camera.get_zoom())
	var global_click_position = camera.get_camera_position() + (click_position - camera.get_viewport_rect().size/2)
	print(global_click_position)
	
	var coord = world_to_map(camera.get_global_mouse_position()*camera.scale)
	print(coord)
	set_cell(coord.x,coord.y,-1)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
