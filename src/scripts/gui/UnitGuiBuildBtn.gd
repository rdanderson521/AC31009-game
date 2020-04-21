extends Button

var building: String
var is_city: bool
var is_district: bool

func _ready():
	self.connect("pressed",self,"pressed")
	SignalManager.connect("unit_selected",self,"unit_selected")

func init(building):
	self.building = building["name"]
	self.is_city = building["is_city"]
	self.is_district = building["is_district"]
	self.find_node("Name").text = building["name"]
	self.find_node("Turns").text = str(building["build_turns"]) + " turns"
	self.connect("pressed",self,"pressed")

func pressed():
	SignalManager.build_btn_click(self.building)
	
func unit_selected(unit):
	if (unit.can_build_city and self.is_city) or (unit.can_build and self.is_district):
		self.visible = true
	else:
		self.visible = false
	
