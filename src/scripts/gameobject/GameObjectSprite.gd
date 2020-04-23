extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _init():
	self.connect("texture_changed",self,"texture_changed")

func texture_changed():
	var new_size = texture.get_size()
	if new_size.x != Hex.width:
		self.scale = Vector2(Hex.width/new_size.x,Hex.width/new_size.x)
	else:
		self.scale = Vector2(1,1)
	if new_size.y * self.scale.y > Hex.height:
		self.offset.y = -((new_size.y * self.scale.y) - Hex.height)/2
	else:
		self.offset.y = 0
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
