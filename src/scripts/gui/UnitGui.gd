extends "res://scripts/gui/GuiPanel.gd"

func _init():
	SignalManager.connect("unit_selected",self,"unit_selected")
	SignalManager.connect("unit_unselected",self,"unit_unselected")
	self.visible = false

func unit_selected(unit):
	find_node("UnitName").text = unit.type
	find_node("SpriteTexture").texture = unit.find_node("Sprite").texture
	find_node("HealthBar").max_value = unit.health_max
	find_node("HealthBar").value = unit.health
	find_node("UnitAttack").text = str(unit.attack)
	find_node("UnitDefence").text = str(unit.defence)
	find_node("UnitMoves").text = str(unit.moves_left)
	self.visible = true
	
func unit_unselected():
	self.visible = false
