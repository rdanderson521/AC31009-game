extends "res://scripts/gui/GuiPanel.gd"


var curr_building: Building
var btn_list: Dictionary
var btn_list_container: Node

func _init():
	SignalManager.connect("building_selected",self,"building_selected")
	SignalManager.connect("building_unselected",self,"building_unselected")
	SignalManager.connect("health_change",self,"health_change")
	SignalManager.connect("build_options_updated",self,"build_options_updated")
	self.visible = false
	self.btn_list = Dictionary()
	
func _ready():
	self.btn_list_container = self.find_node("BuildingBtnLst",true,false)

func building_selected(building):
	self.curr_building = building
	find_node("BuildingName").text = building.type
	find_node("BuildingTexture").texture = building.find_node("Sprite").texture
	find_node("HealthBar").max_value = building.health_max
	find_node("HealthBar").value = building.health
	find_node("BuildingAttack").text = str(building.attack)
	find_node("BuildingDefence").text = str(building.defence)
	self.reset_buttons()
	self.update_build_info()
	self.visible = true
	
func update_build_info():
	if self.curr_building is City and self.curr_building.mode == Building.BUILD:
		var min_done = -1
		for i in self.curr_building.build_options[self.curr_building.build_curr]["cost"].keys():
			print(i)
			var temp_min_done = 1-(self.curr_building.build_resources_left[i]/self.curr_building.build_options[self.curr_building.build_curr]["cost"][i])
			if min_done == -1:
				min_done = temp_min_done
			else:
				min_done = min(temp_min_done,min_done)
		if min_done >=0:
			find_node("CurrentBuildContainer").visible = true
			find_node("CurrentBuild").text = self.curr_building.build_curr
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
	
func reset_buttons():
	for i in self.curr_building.build_options.keys():
		if !self.btn_list.has(i):
			var btn = preload("res://scenes/gui/BuildingGuiBuildBtn.tscn").instance()
			btn.script = preload("res://scripts/gui/BuildingGuiBuildBtn.gd")
			btn.find_node("Name").text = str(self.curr_building.build_options[i]["name"])
			btn.find_node("Icon").texture = load(str(self.curr_building.build_options[i]["texture"]))
			btn.thing_to_make = str(self.curr_building.build_options[i]["name"])
			btn.init(i)
			self.btn_list[i] = btn
			self.btn_list_container.add_child(btn)
			
	for i in self.btn_list.keys():
		if self.curr_building.build_options.has(i):
			var longest_turns = -1
			for j in self.curr_building.build_options[i]["cost"].keys():
				print(i)
				var temp_min_done = (self.curr_building.build_options[i]["cost"][j]/self.curr_building.resources_per_turn[j])
				if longest_turns == -1:
					longest_turns = temp_min_done
				else:
					longest_turns = max(temp_min_done,longest_turns)
			if longest_turns >=0:
				btn_list[i].find_node("Turns").text = str(ceil(longest_turns))+" Turns"
			btn_list[i].visible = true
			if self.curr_building.build_options[i]["enabled"]:
				btn_list[i].disabled = false
			else:
				btn_list[i].disabled = true
		else:
			btn_list[i].visible = false
	
func build_options_updated(obj):
	if obj == self.curr_building:
		self.reset_buttons()
		self.update_build_info()
	
func building_unselected():
	self.visible = false
	curr_building = null
	
func health_change(obj,h):
	if obj == curr_building:
		find_node("HealthBar").value = h
