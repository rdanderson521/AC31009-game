extends "res://scripts/gui/GuiPanel.gd"

var player: Player 

func _init():
	SignalManager.connect("player_turn_started",self,"turn_started")
	
func _ready():
	self.player = self.find_parent("Player*")

func camera_changed(player):
	if player == self.player:
		self.visible = true
	else:
		self.visible = false
	
func turn_started(player):
	if player == self.player:
		self.find_node("EndTurnBtn").disabled = false
		self.find_node("TurnLbl").text = str(player.turn)
		self.visible = true
		
func turn_ended():
	self.find_node("EndTurnBtn").disabled = true
	
	
