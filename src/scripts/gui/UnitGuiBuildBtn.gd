extends Button

var building: Dictionary

func _ready():
	pass

func init(building):
	self.building = building
	self.find_node("Name").text = building["name"]
	self.find_node("Turns").text = str(building["build_turns"]) + " turns"
	self.connect("pressed",self,"pressed")

func pressed():
	SignalManager.build_btn_click(self.building["name"])
	

