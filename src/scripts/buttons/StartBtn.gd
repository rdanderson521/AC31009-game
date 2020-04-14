extends Button

func _ready():
	self.connect("pressed",SignalManager,"start_btn_clicked")

