extends Node2D

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
			print("parse successful")
			units = f_parsed.result["units"]
			buildings = f_parsed.result["buildings"]
			print("units: " + str(units))
			print("buildings: " + str(buildings))
			
			var player = preload("res://player.gd").new(Vector2(2,2),units,self)
			
		else:
			print("json parse error")
			
	var start_unit = sprite_template.instance()
	start_unit.init("test",100,5,5,5,true,true,"icon2.png",Vector2(4,4))


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

