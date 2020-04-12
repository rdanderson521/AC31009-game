extends Button

func _ready():
	self.connect("pressed",SignalManager,"tech_tree_btn_click")

