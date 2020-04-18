extends "res://scripts/gui/GuiPanel.gd"

func turn_ended():
	self.find_node("EndTurnBtn").disabled = true
	print("end turn btn disabled")
	
func turn_started():
	self.find_node("EndTurnBtn").disabled = false
	print("end turn btn enabled")
