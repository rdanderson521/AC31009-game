extends "res://scripts/gui/GuiPanel.gd"

var instructions: Dictionary
var queue: Array
var current: String

func _init():
	self.visible = false
	self.instructions = Dictionary()
	self.queue = Array()
	self.instructions["turn_start"] = {"show_again":true,"keep":true,"text":"To select your units or buildings left click on them. When selected you can make them perform tasks such as building and moving.\n\nTo move the camera use the arrow keys and the scroll wheel to zoom.\n\nIt is a good idea to use a unit to explore areas of the map you have not yet seen (hidden behind the grey fog)."}
	self.instructions["unit_selected"] = {"show_again":true,"keep":false,"text":"To make your selected unit move, right click on the map somewhere. The unit will move as far as it can in this turn, it may need multiple turns to go longer distances.\n\nTo attack an enemy unit/building you should right click on the unit/building you want to attack."}
	self.instructions["building_selected"] = {"show_again":true,"keep":false,"text":"Buildings are able to make units, you can see how many turns it will take to make each type of unit on the buttons when a building is selected.\n\nYou can upgrade your cities by building buildings in the area around your city. This requires Builder units."}
	self.instructions["builder_selected"] = {"show_again":true,"keep":false,"text":"To make your selected unit move, right click on the map somewhere. The unit will move as far as it can in this turn, it may need multiple turns to go longer distances.\n\nSome units can build, to see what a unit can build see the buttons on the right of the unit panel at the bottom left.\n\nWhen building a city the unit will be consumed doing so.\n\nWhen building improvements for cities you must be in city borders and certain improvements can only be done on certain tiles"}
	SignalManager.connect("player_turn_started",self,"turn_start")
	SignalManager.connect("unit_selected",self,"unit_selected")
	SignalManager.connect("building_selected",self,"building_selected")
	
# Called when the node enters the scene tree for the first time.

func _ready():
	self.find_node("CloseBtn",true,false).connect("pressed",self,"close")

func add_help(help):
	if self.instructions[help]["show_again"]:
		self.set_text(self.instructions[help]["text"])
		if !self.visible:
			print("not vis")
			self.find_node("CheckBox",true,false).pressed = false
			self.current = help
			self.visible = true
		else:
			if self.current != help:
				self.find_node("CheckBox",true,false).pressed = false
				print("queue",self.queue)
				print("current",self.current)
				if !self.queue.has(self.current):
					print("queue")
					if self.instructions[self.current]["keep"]:
						self.queue.push_front(self.current)
				if self.queue.has(help):
					print("deete")
					self.queue.erase(help)
				self.current = help

func set_text(text):
	var text_box = self.find_node("RichTextLabel",true,false)
	text_box.text = text
	yield(get_tree(), "idle_frame")
#	self.set_size(Vector2(text_box.get_size().x, ))
	self.margin_bottom = (text_box.get_v_scroll().get_max()+80)

func turn_start(player):
	print(player.name," turn start help")
	add_help("turn_start")
	
func unit_selected(unit):
	if unit.can_build or unit.can_build_city:
		add_help("builder_selected")
	else:
		add_help("unit_selected")
		
func building_selected(building):
	print("building")
	add_help("building_selected")
	
func close():
	if self.find_node("CheckBox",true,false).pressed:
		self.find_node("CheckBox",true,false).pressed = false
		self.instructions[self.current]["show_again"] = false
	if self.queue.empty():
		self.visible = false
	else:
		var new_instruction = self.queue.pop_front()
		self.set_text(self.instructions[new_instruction]["text"])
	

