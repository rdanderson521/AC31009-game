extends TileMap

func _init():
	self.cell_custom_transform.x.x = (3*Hex.width)/4
	self.cell_custom_transform.x.y = 14#Hex.height/2
	self.cell_custom_transform.y.y = 28#Hex.height
	
	self.cell_size.y = 32
	self.cell_size.y = 48
	
	self.position = Vector2(-16,-32)
	self.scale.y = Hex.height/28


