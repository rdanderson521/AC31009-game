extends Area2D

func _ready():
	self.connect("mouse_entered",self,"on_mouse_entered")
	self.connect("mouse_exited",self,"on_mouse_exited")
	self.connect("input_event",self,"on_input_event")

func on_mouse_entered():
	SignalManager.mouse_entered_game_obj(self.get_parent())
	
func on_mouse_exited():
	SignalManager.mouse_exited_game_obj(self.get_parent())
	
func on_input_event(viewport,event,shape_idx):
	print (event.as_text())
	if event == InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			SignalManager.mouse_left_game_obj(self.get_parent())
		elif event.button_index == BUTTON_RIGHT and event.is_pressed():
			SignalManager.mouse_right_game_obj(self.get_parent())
