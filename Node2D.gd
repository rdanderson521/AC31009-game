extends Node2D

var hex = preload("res://HexOperations.gd").Hex
var sprite_template = preload("res://spriteTemplate.tscn")

var units 
var buildings
var sprites = Array()
var draw_list = Array()

func _ready():
	var f = File.new()
	if(f.file_exists("res://units.json")):
		f.open("res://units.json",File.READ)
		var f_text = f.get_as_text()
		f.close()
		print("file: " + str(f_text))
		var f_parsed = JSON.parse(f_text)
		if f_parsed.error == OK and typeof(f_parsed.result) == TYPE_DICTIONARY:
			units = f_parsed.result["units"]
			buildings = f_parsed.result["buildings"]
			print("units: " + str(units))
			print("buildings: " + str(buildings))
		
	sprites.push_back(sprite_template.instance())
	
	sprites.back().init()

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

	var hex_coord = hex.point_to_hex(global_click_position)
	emit_signal("tilemap_clicked",hex_coord)
	print("hex_coord: " + str(hex_coord))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

