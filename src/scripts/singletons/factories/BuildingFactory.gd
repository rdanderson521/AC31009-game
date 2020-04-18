extends Node

var game_object = preload("res://scenes/GameObject.tscn")
var building_script = preload("res://scripts/gameobject/building/BuildingNode.gd")

var building_templates: Array
var building_templates_by_name: Dictionary

var debug = false

func _init():
	var templates = JsonParser.parse_json_file("res://resources/jsonconfigs/buildings.json")
	if typeof(templates) == TYPE_ARRAY:
		print("buildings imported")
		templates = check_templates(templates)
		self.building_templates = templates
		self.building_templates_by_name = Dictionary()
		for i in building_templates:
			building_templates_by_name[i.name] = i
		SignalManager.building_file_read()
	else:
		print("err reading buildings config")

func init_building() -> Building:
	var building = game_object.instance()
	building.set_script(building_script)
	return building

func check_templates(templates):
	for i in templates:
		
		if !i.has("name"):
			if debug:
				print("err: check building json")
			templates.erase(i)
			continue
			
		if !i.has("is_city"):
			if debug:
				print("err: check building json")
			templates.erase(i)
			continue
			
		if !i.has("is_district"):
			if debug:
				print("err: check building json")
			templates.erase(i)
			continue
		
		if !i.has("health"):
			if debug:
				print("err: check building json")
			templates.erase(i)
			continue
			
		if !i.has("damage"):
			if debug:
				print("err: check building json")
			i["damage"] = 0
			
		if !i.has("damage_range"):
			if debug:
				print("err: check building json")
			i["damage_range"] = 0
			
		if !i.has("defence"):
			if debug:
				print("err: check building json")
			i["defence"] = 0
			
		if !i.has("improvements"):
			if debug:
				print("err: check building json")
			i["improvements"] = null
		
		if !i.has("cost"):
			if debug:
				print("err: check building json")
			i["cost"] = null
			
		if !i.has("build_turns"):
			if debug:
				print("err: check building json")
			i["build_turns"] = 0
			
		if !i.has("texture"):
			if debug:
				print("err: check building json")
			templates.erase(i)
			continue
	return templates

func build_building(to_build,hex,player):
	var building = init_building()
	var template = building_templates_by_name[to_build]
	
	building.hex_pos = hex
	building.position = Hex.hex_to_point(hex)
	building.type = template["name"]
	building.is_city = template["is_city"]
	building.is_district = template["is_district"]
	building.health_max = template["health"]
	building.health = template["health"]
	building.attack = template["damage"]
	building.attack_range = template["damage_range"]
	building.defence = template["defence"]
	building.improvements = template["improvements"]
	building.texture = template["texture"]
	player.add_child(building)
	
	return building
	


	
