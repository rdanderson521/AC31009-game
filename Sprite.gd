extends Sprite

func _on_mouse_entered():
	self.scale.x += 0.1
	self.scale.y += 0.1


func _on_mouse_exited():
	self.scale.x -= 0.1
	self.scale.y -= 0.1
