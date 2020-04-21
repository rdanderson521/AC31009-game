extends "res://scripts/gui/GuiPanel.gd"


var curr_building: Unit

func _init():
	SignalManager.connect("building_selected",self,"building_selected")
	SignalManager.connect("building_unselected",self,"building_unselected")
	SignalManager.connect("health_change",self,"health_change")
	SignalManager.connect("moves_left_change",self,"moves_left_change")
	SignalManager.connect("building_file_read",self,"add_building_buttons")
	self.visible = false
	
func _ready():
	var btn_list = self.find_node("BuildingBtnLst")
	if btn_list != null:
		#print("building list")
		for i in UnitFactory.unit_templates:
			#print("test: "+ str(i["name"]))
			var btn = preload("res://scenes/gui/BuildingGuiBuildBtn.tscn").instance()
			btn.script = preload("res://scripts/gui/BuildingGuiBuildBtn.gd")
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
	self.visible = true
	
func building_unselected():
	self.visible = false
	curr_building = null
	
func health_change(obj,h):
	if obj == curr_building:
		find_node("HealthBar").value = h
