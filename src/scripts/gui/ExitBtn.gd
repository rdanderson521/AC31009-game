extends Button


func _init():
	self.connect("pressed",self,"pressed")

func pressed():
	get_tree().quit()
