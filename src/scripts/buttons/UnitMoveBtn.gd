extends Button

func _ready():
	self.connect("pressed",SignalManager,"unit_move_btn_click")

