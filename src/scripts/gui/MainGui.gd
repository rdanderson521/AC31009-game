extends "res://scripts/gui/GuiPanel.gd"

var player: Player 

func _init():
	SignalManager.connect("player_turn_started",self,"turn_started")
	SignalManager.connect("enable_end_turn_btn",self,"enable_end_turn_btn")
	
func _ready():
	self.player = self.find_parent("Player*")

func camera_changed(player):
	if player == self.player:
		self.visible = true
	else:
		self.visible = false
	
func turn_started(player):
	if player == self.player:
		if !GlobalConfig.testing:
			self.find_node("EndTurnBtn").disabled = true
		self.find_node("TurnLbl").text = str(player.turn)
		self.find_node("PlayerTurnLabel").text = "Your Turn"
		self.visible = true
	elif player is AI:
		self.find_node("PlayerTurnLabel").text = "AI " + player.name + "s' Turn"
		
func enable_end_turn_btn(player):
	if player == self.player:
		self.find_node("EndTurnBtn").disabled = false
		
func turn_ended():
	if !GlobalConfig.testing:
		self.find_node("EndTurnBtn").disabled = true
	
	
