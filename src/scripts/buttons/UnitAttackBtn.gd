extends Button

func _ready():
	self.connect("pressed",SignalManager,"unit_attack_btn_click")

