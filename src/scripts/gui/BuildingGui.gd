extends "res://scripts/gui/GuiPanel.gd"


var curr_building: Building

func _init():
	SignalManager.connect("building_selected",self,"building_selected")
	SignalManager.connect("building_unselected",self,"building_unselected")
	SignalManager.connect("health_change",self,"health_change")
	self.visible = false
	
func _ready():
	var btn_list = self.find_node("BuildingBtnLst")
	if btn_list != null:
		for i in UnitFactory.unit_templates:
			var btn = preload("res://scenes/gui/BuildingGuiBuildBtn.tscn").instance()
			btn.script = preload("res://scripts/gui/BuildingGuiBuildBtn.gd")
			btn.find_node("Name").text = str(i["name"])
			btn.find_node("Turns").text = str(i["cost"])
			btn.find_node("Icon").texture = load(str(i["texture"]))
			btn.thing_to_make = str(i["name"])
			btn.init(i)
			btn_list.add_child(btn)
			

func building_selected(building):
	self.curr_building = building
	find_node("BuildingName").text = building.type
	find_node("BuildingTexture").texture = building.find_node("Sprite").texture
	find_node("HealthBar").max_value = building.health_max
	find_node("HealthBar").value = building.health
	find_node("BuildingAttack").text = str(building.attack)
	find_node("BuildingDefence").text = str(building.defence)
	if building is City and building.mode == Building.BUILD:
		var min_done = -1
		for i in building.build_options[building.build_curr]["cost"].keys():
			print(i)
			var temp_min_done = 1-(building.build_resources_left[i]/building.build_options[building.build_curr]["cost"][i])
			if min_done == -1:
				min_done = 1-(building.build_resources_left[i]/building.build_options[building.build_curr]["cost"][i])
			else:
				min_done = min(temp_min_done,min_done)
		if min_done >=0:
			find_node("CurrentBuildContainer").visible = true
			find_node("CurrentBuild").text = building.build_curr
			find_node("BuildProgressContainer").visible = true
			find_node("BuildProgress").max_value = 1
			find_node("BuildProgress").value = min_done
			print(min_done)
		else:
			find_node("CurrentBuildContainer").visible = false
			find_node("BuildProgressContainer").visible = false
	else:
		find_node("CurrentBuildContainer").visible = false
		find_node("BuildProgressContainer").visible = false
	var btn_list = Dictionary()
	for i in self.find_node("BuildingBtnLst").get_children():
		i.visible = false
		btn_list[i.find_node("Name").text] = i
	for i in building.build_options.values():
		if i["name"] in btn_list.keys():
			btn_list[i["name"]].visible = true
	self.visible = true
	
func building_unselected():
	self.visible = false
	curr_building = null
	
func health_change(obj,h):
	if obj == curr_building:
		find_node("HealthBar").value = h
