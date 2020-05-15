extends Node

var game_object = preload("res://scenes/GameObject.tscn")
var unit_script = preload("res://scripts/gameobject/unit/UnitNode.gd")

var unit_templates: Array
var unit_templates_by_name: Dictionary
var debug = false

func _init():
	var templates = JsonParser.parse_json_file("res://resources/jsonconfigs/units.json")
	if typeof(templates) == TYPE_ARRAY:
		print("units imported")
		templates = check_templates(templates)
		self.unit_templates = templates
		self.unit_templates_by_name = Dictionary()
		for i in unit_templates:
			unit_templates_by_name[i.name] = i
	else:
		print("err reading units config")
		

func init_unit() -> Unit:
	var unit = game_object.instance()
	unit.set_script(unit_script)
	return unit
	
func check_templates(templates):
	for i in templates:
		
		if !i.has("name"):
			if debug:
				print("err: check unit json")
			templates.erase(i)
			continue
			
		if !i.has("health"):
			if debug:
				print("err: check unit json")
			templates.erase(i)
			continue
		
		if !i.has("damage"):
			i["damage"] = 0
			if debug:
				print("err: check unit json")
		
		if !i.has("damage_range"):
			i["damage_range"] = 0
			if debug:
				print("err: check unit json")
				
		if !i.has("defence"):
			i["defence"] = 0
			if debug:
				print("err: check unit json")
		
		if !i.has("move_range"):
			if debug:
				print("err: check unit json")
			templates.erase(i)
			continue
		
		if !i.has("can_build_city"):
			i["can_build_city"] = false
			if debug:
				print("err: check unit json")
			#continue
		
		if !i.has("can_build"):
			i["can_build"] = false
			if debug:
				print("err: check unit json")
		
		if !i.has("can_trade"):
			i["can_trade"] = false
			if debug:
				print("err: check unit json")
			
		if !i.has("texture"):
			if debug:
				print("err: check unit json")
			templates.erase(i)
			continue
	return templates
	
func start_units(hex,player) -> Array:
	var start_area = Hex.hex_in_range(1,hex)
	start_area.shuffle()
	
	var start_units = Array()
	
	for i in unit_templates:
		if i.has("start"):
			for j in range(i["start"]):
				if !start_area.empty():
					var unit = self.build_unit(i["name"],start_area.pop_back(),player)
#					var unit = init_unit()
#					player.add_child(unit)
#					unit.hex_pos = start_area.pop_back()
#					unit.position = Hex.hex_to_point(unit.hex_pos)
#					unit.type = i["name"]
#					unit.health_max = i["health"]
#					unit.health = i["health"]
#					unit.attack = i["damage"]
#					unit.attack_range = i["damage_range"]
#					unit.defence = i["defence"]
#					unit.move_range = i["move_range"]
#					unit.can_build_city = i["can_build_city"]
#					unit.can_build = i["can_build"]
#					unit.can_trade = i["can_trade"]
#					unit.texture = i["texture"]
					start_units.push_back(unit)
					
	return start_units
	
func build_unit(unit_to_build,hex,player) -> Unit:

	var unit_template = unit_templates_by_name[unit_to_build]
	var unit = init_unit()
#	player.find_node("YSort").add_child(unit)
	unit.hex_pos = hex
	unit.position = Hex.hex_to_point(unit.hex_pos)
	unit.type = unit_template["name"]
	unit.health_max = unit_template["health"]
	unit.health = unit_template["health"]
	unit.attack = unit_template["damage"]
	unit.attack_range = unit_template["damage_range"]
	unit.defence = unit_template["defence"]
	unit.move_range = unit_template["move_range"]
	unit.can_build_city = unit_template["can_build_city"]
	unit.can_build = unit_template["can_build"]
	unit.can_trade = unit_template["can_trade"]
	unit.texture = unit_template["texture"]
	unit.player = player
	return unit
	
func copy_unit(unit_to_copy) -> Unit:

	var unit = init_unit()
	unit.hex_pos = unit_to_copy.hex_pos
	unit.position = unit_to_copy.position
	unit.type = unit_to_copy.type
	unit.health_max = unit_to_copy.health_max
	unit.health = unit_to_copy.health
	unit.attack = unit_to_copy.attack
	unit.attack_range = unit_to_copy.attack_range
	unit.defence = unit_to_copy.defence
	unit.move_range = unit_to_copy.move_range
	unit.can_build_city = unit_to_copy.can_build_city
	unit.can_build = unit_to_copy.can_build
	unit.can_trade = unit_to_copy.can_trade
	unit.player = null
	unit.visible = false
	return unit
