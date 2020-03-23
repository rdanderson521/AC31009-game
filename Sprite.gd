extends Sprite

var selected = false
var mouse_entered = false

func _on_mouse_entered():
	if !selected:
		self.scale.x += 0.1
		self.scale.y += 0.1
	mouse_entered = true


func _on_mouse_exited():
	if !selected:
		self.scale.x -= 0.1
		self.scale.y -= 0.1
	mouse_entered = false


func _on_Node2D_is_selected(val):
	selected = val
	if val:
		if !mouse_entered:
			self.scale.x += 0.1
			self.scale.y += 0.1
	else:
		if !mouse_entered:
			self.scale.x -= 0.1
			self.scale.y -= 0.1
		
		
