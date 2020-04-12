extends Control

func _ready():
	self.connect("mouse_entered",SignalManager,"mouse_entered_gui")
	self.connect("mouse_exited",SignalManager,"mouse_exited_gui")

