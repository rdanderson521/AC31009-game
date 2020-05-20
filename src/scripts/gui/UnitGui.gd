extends "res://scripts/gui/GuiPanel.gd"

var curr_unit: Unit

func _init():
	SignalManager.connect("unit_selected",self,"unit_selected")
	SignalManager.connect("unit_unselected",self,"unit_unselected")
	SignalManager.connect("health_change",self,"health_change")
	SignalManager.connect("moves_left_change",self,"moves_left_change")
	SignalManager.connect("building_file_read",self,"add_building_buttons")
	SignalManager.connect("unit_moved",self,"unit_moved")
	SignalManager.connect("build_options_updated",self,"build_options_updated")
	self.visible = false
	
func _ready():
	var btn_list = self.find_node("BuildingBtnLst")
	if btn_list != null:
		for i in BuildingFactory.building_templates:
			if i["is_city"] or i["is_district"]:
				var btn = preload("res://scenes/gui/UnitGuiBuildBtn.tscn").instance()
				btn.script = preload("res://scripts/gui/UnitGuiBuildBtn.gd")
				btn.init(i)
				btn.find_node("BuildIcon",true,false).texture = load(i["texture"])
				btn_list.add_child(btn)
			
func unit_selected(unit):
	self.curr_unit = unit
	find_node("UnitName").text = unit.type
	find_node("SpriteTexture").texture = unit.find_node("Sprite").texture
	find_node("HealthBar").max_value = unit.health_max
	find_node("HealthBar").value = unit.health
	find_node("UnitAttack").text = str(unit.attack)
	find_node("UnitDefence").text = str(unit.defence)
	find_node("UnitMoves").text = str(unit.moves_left)
	self.curr_unit.update_build_options()
	self.reset_buttons()
	
	self.visible = true
	
func unit_moved(unit,from,to):
	if unit == self.curr_unit:
		self.reset_buttons()
		
func build_options_updated(obj):
	if obj == self.curr_unit:
		self.reset_buttons()
	
func reset_buttons():
	var btn_list = Dictionary()
	for i in self.find_node("BuildingBtnLst").get_children():
		i.visible = false
		btn_list[i.find_node("Name").text] = i
	for i in self.curr_unit.build_options.values():
		if btn_list.has(i["name"]):
			btn_list[i["name"]].visible = true
			if i["enabled"]:
				btn_list[i["name"]].disabled = false
			else:
				btn_list[i["name"]].disabled = true
	
func unit_unselected():
	self.visible = false
	curr_unit = null
	
func health_change(obj,h):
	if obj == curr_unit:
		find_node("HealthBar").value = h
		
func moves_left_change(unit,m):
	if unit == curr_unit:
		find_node("UnitMoves").text = str(m)
