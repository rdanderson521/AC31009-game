extends Control

func _init():
	self.connect("mouse_entered",SignalManager,"mouse_entered_gui")
	self.connect("mouse_exited",SignalManager,"mouse_exited_gui")
