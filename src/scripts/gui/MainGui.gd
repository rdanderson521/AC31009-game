extends "res://scripts/gui/GuiPanel.gd"

func turn_ended():
	self.find_node("EndTurnBtn").disabled = true
	print("test")
	
func turn_started():
	self.find_node("EndTurnBtn").disabled = false
