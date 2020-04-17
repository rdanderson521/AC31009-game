extends Button

func _ready():
	self.connect("toggled",SignalManager,"unit_move_btn_click")

