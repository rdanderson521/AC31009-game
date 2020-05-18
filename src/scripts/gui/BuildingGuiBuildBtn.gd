extends Button

var thing_to_make: String
var is_upgrade: bool
var is_unit: bool
var cost: Dictionary

func _init():
	is_unit = false
	is_upgrade = false
	cost = Dictionary()

func _ready():
	self.connect("pressed",self,"pressed")

func init(obj):
	if obj is Unit:
		is_unit = true
		thing_to_make = obj.type

func pressed():
	print("build pressed")
	SignalManager.build_btn_click(self.thing_to_make)

