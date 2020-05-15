extends Node

var game_object = preload("res://scenes/GameObject.tscn")
var building_script = preload("res://scripts/gameobject/building/BuildingNode.gd")
var city_script = preload("res://scripts/gameobject/building/CityNode.gd")

var building_templates: Array
var building_templates_by_name: Dictionary

var debug = false

func _init():
	var templates = JsonParser.parse_json_file("res://resources/jsonconfigs/buildings.json")
	if typeof(templates) == TYPE_ARRAY:
		templates = check_templates(templates)
		self.building_templates = templates
		self.building_templates_by_name = Dictionary()
		for i in building_templates:
			building_templates_by_name[i["name"]] = i
		SignalManager.building_file_read()
	else:
		print("err reading buildings config")

func init_building() -> Building:
	var building = game_object.instance()
	building.set_script(building_script)
	return building
	
func init_city() -> City:
	var city = game_object.instance()
	city.set_script(city_script)
	return city

func check_templates(templates):
	for i in templates.duplicate():
		if !i.has("name"):
			if debug:
				print("err: check building json name")
			templates.erase(i)
			continue
		
		if !i.has("is_city"):
			if debug:
				print("err: check building json city")
			i["is_city"] = false
			
		if !i.has("is_district"):
			if debug:
				print("err: check building json district")
			i["is_district"] = false
		
		if !i.has("health"):
			if debug:
				print("err: check building json health")
			templates.erase(i)
			continue
			
		if !i.has("damage"):
			if debug:
				print("err: check building json damage")
			i["damage"] = 0
			
		if !i.has("damage_range"):
			if debug:
				print("err: check building json range")
			i["damage_range"] = 0
			
		if !i.has("defence"):
			if debug:
				print("err: check building json defence")
			i["defence"] = 0
			
		if !i.has("improvements"):
			if debug:
				print("err: check building json improvements")
			i["improvements"] = null
		
		if !i.has("cost"):
			if debug:
				print("err: check building json cost")
			i["cost"] = null
			
		if !i.has("build_turns"):
			if debug:
				print("err: check building json turns")
			i["build_turns"] = 0
			
		if !i.has("texture"):
			if debug:
				print("err: check building json texture")
			templates.erase(i)
			continue
	return templates

func build_building(to_build,hex,player):
	var building
	var template = building_templates_by_name[to_build]
	if template["is_city"]:
		building = init_city()
		building.area = Hex.hex_in_range(1,hex)
	else:
		building = init_building()
	building.hex_pos = hex
	building.position = Hex.hex_to_point(hex)
	building.type = template["name"]
	building.health_max = template["health"]
	building.health = template["health"]
	building.attack = template["damage"]
	building.attack_range = template["damage_range"]
	building.defence = template["defence"]
	building.improvements = template["improvements"]
	building.texture = template["texture"]
	player.add_child(building)
	
	return building
	
func copy_building(to_copy: Building):
	var building = init_building()
	building.hex_pos = to_copy.hex_pos
	building.position = to_copy.hex_pos
	building.type = to_copy.type
	if building is City:
		building.area = to_copy.area.duplicate()
	building.health_max = to_copy.health_max
	building.health = to_copy.health
	building.attack = to_copy.attack
	building.attack_range = to_copy.attack_range
	building.defence = to_copy.defence
	building.improvements = to_copy.improvements.duplicate()
	building.texture = to_copy.texture
	
	return building
	
func copy_city(to_copy: City):
	var city = init_city()
	city.hex_pos = to_copy.hex_pos
	city.position = to_copy.hex_pos
	city.type = to_copy.type
	city.area = to_copy.area.duplicate()
	city.health_max = to_copy.health_max
	city.health = to_copy.health
	city.attack = to_copy.attack
	city.attack_range = to_copy.attack_range
	city.defence = to_copy.defence
	city.improvements = to_copy.improvements.duplicate()
	city.texture = to_copy.texture
	
	return city


	
