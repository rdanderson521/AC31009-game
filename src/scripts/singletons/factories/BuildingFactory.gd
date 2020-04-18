extends Node

var game_object = preload("res://scenes/GameObject.tscn")
var building_script = preload("res://scripts/gameobject/building/BuildingNode.gd")

var building_templates

var debug = false

func _init():
	var templates = JsonParser.parse_json_file("res://resources/jsonconfigs/buildings.json")
	if typeof(templates) == TYPE_ARRAY:
		print("buildings imported")
		templates = check_templates(templates)
		self.building_templates = templates
	else:
		print("err reading units config")

func init_building() -> Building:
	var building = game_object.instance()
	building.set_script(building_script)
	return building

func check_templates(templates):
	for i in templates:
		
		if !i.has("name"):
			if debug:
				print("err: check unit json")
			templates.erase(i)
			continue
			
		if !i.has("is_city"):
			if debug:
				print("err: check unit json")
			i["is_city"] = false
		
		if !i.has("health"):
			if debug:
				print("err: check unit json")
			templates.erase(i)
			continue
			
		if !i.has("damage"):
			if debug:
				print("err: check unit json")
			i["damage"] = 0
			
		if !i.has("damage_range"):
			if debug:
				print("err: check unit json")
			i["damage_range"] = 0
			
		if !i.has("defence"):
			if debug:
				print("err: check unit json")
			i["defence"] = 0
			
		if !i.has("improvements"):
			if debug:
				print("err: check unit json")
			i["improvements"] = null
		
		if !i.has("cost"):
			if debug:
				print("err: check unit json")
			i["cost"] = null
			
		if !i.has("build_turns"):
			if debug:
				print("err: check unit json")
			i["build_turns"] = 0
			
		if !i.has("texture"):
			if debug:
				print("err: check unit json")
			templates.erase(i)
			continue

func build_building(building,hex):



	
