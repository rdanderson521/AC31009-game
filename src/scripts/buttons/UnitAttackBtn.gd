extends Button

func _ready():
	self.connect("toggled",SignalManager,"unit_attack_btn_click")

