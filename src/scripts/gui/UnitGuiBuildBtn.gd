extends Button

var building: Dictionary

func _ready():
	SignalManager.connect("unit_selected",self,"unit_selected")

func init(building):
	self.building = building
	self.find_node("Name").text = building["name"]
	self.find_node("Turns").text = str(building["build_turns"]) + " turns"
	self.connect("pressed",self,"pressed")

func pressed():
	SignalManager.build_btn_click(self.building["name"])
	
#func unit_selected(unit):
#	if unit.can_build(self.building["name"]):
#		self.visible = true
#	else:
#		self.visible = false
	
