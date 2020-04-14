extends Node2D


func _ready():
	pass

signal tilemap_clicked(hex_pos)

func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		print("node: "+str(event.position))
		self.on_click(event.position)
		
func on_click(click_position):
	var camera = $Camera2D
	var global_click_position =  (camera.get_camera_position() + (( click_position - camera.get_viewport().get_visible_rect().size/2) * camera.scale * camera.get_zoom()))

	var hex_coord = Hex.point_to_hex(global_click_position)
	emit_signal("tilemap_clicked",hex_coord)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

