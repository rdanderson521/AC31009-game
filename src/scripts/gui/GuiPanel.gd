extends Control

func _init():
	self.connect("mouse_entered",self,"mouse_entered")
	self.connect("mouse_exited",self,"mouse_exited")
	self.connect("visibility_changed",self,"visibility_changed")

func mouse_entered():
	SignalManager.mouse_entered_gui(self)
	
func mouse_exited():
	SignalManager.mouse_exited_gui(self)
	
func visibility_changed():
	if !self.visible:
		SignalManager.gui_closed(self)
