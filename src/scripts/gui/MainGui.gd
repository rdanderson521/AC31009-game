extends "res://scripts/gui/GuiPanel.gd"

func turn_ended():
	self.find_node("EndTurnBtn").disabled = true
	self.visible = false
	print("end turn btn disabled")
	
func turn_started(turn):
	self.find_node("EndTurnBtn").disabled = false
	self.find_node("TurnLbl").text = str(turn)
	self.visible = true
	print("end turn btn enabled")
	