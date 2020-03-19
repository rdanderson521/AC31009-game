extends Node2D

var hex = preload("res://HexOperations.gd").Hex
signal sprite_click

var sprites

func _ready():
	sprites = Dictionary()
	sprites[$Sprite.hex_pos] = $Sprite

func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.is_pressed():
		print("node: "+str(event.position))
		self.on_click(event.position)
		
func on_click(click_position):
	var camera = $Camera2D
	var global_click_position =  (camera.get_camera_position() + (( click_position - camera.get_viewport().get_visible_rect().size/2) * camera.scale * camera.get_zoom()))

	var hex_coord = hex.point_to_hex(global_click_position)
	if sprites.has(hex_coord):
		var sprite = sprites[hex_coord]
		sprite.rand_move()
		sprites.erase(hex_coord)
		sprites[sprite.hex_pos] = sprite
		
	
	#var hex_centre = hex.hex_to_point(hex_coord)




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
