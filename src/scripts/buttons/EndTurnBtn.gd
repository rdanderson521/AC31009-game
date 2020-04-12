extends Button

func _ready():
	self.connect("pressed",SignalManager,"end_turn_btn_click")

