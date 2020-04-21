extends CollisionPolygon2D

func _init():
	var hexagon = PoolVector2Array()
	hexagon.append(Vector2(-Hex.width/4,-Hex.height/2))
	hexagon.append(Vector2(Hex.width/4,-Hex.height/2))
	hexagon.append(Vector2(Hex.width/2,0))
	hexagon.append(Vector2(Hex.width/4,Hex.height/2))
	hexagon.append(Vector2(-Hex.width/4,Hex.height/2))
	hexagon.append(Vector2(-Hex.width/2,0))
	self.polygon = hexagon
