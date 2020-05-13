extends Node2D

var fog_of_war: Array
var visible_tiles: Array

func _ready():
	if !GlobalConfig.testing:
		self.z_index += 4
	pass
	
func draw(fow = null,vis_tiles = null):
	if fow != null:
		self.fog_of_war = fow
	if vis_tiles != null:
		self.visible_tiles = vis_tiles
	self.visible = true
	if !GlobalConfig.testing:
		for i in GlobalConfig.unit_tiles.keys():
			if i in self.visible_tiles:
				GlobalConfig.unit_tiles[i].visible = true
			else:
				GlobalConfig.unit_tiles[i].visible = false
	
	self.update()

func _draw():
	for i in GlobalConfig.map.keys():
		if i in self.fog_of_war:
			var points = Array()
			var pos = Hex.hex_to_point(i)
			points.append(pos + Vector2(-Hex.width/4,-Hex.height/2))
			points.append(pos + Vector2(Hex.width/4,-Hex.height/2))
			points.append(pos + Vector2(Hex.width/2,0))
			points.append(pos + Vector2(Hex.width/4,Hex.height/2))
			points.append(pos + Vector2(-Hex.width/4,Hex.height/2))
			points.append(pos + Vector2(-Hex.width/2,0))
			var polygon = PoolVector2Array(points)
			self.draw_polygon(polygon,PoolColorArray([Color(0.37,0.37,0.37)]))
		if !i in self.fog_of_war and !i in self.visible_tiles:
			var points = Array()
			var pos = Hex.hex_to_point(i)
			points.append(pos + Vector2(-Hex.width/4,-Hex.height/2))
			points.append(pos + Vector2(Hex.width/4,-Hex.height/2))
			points.append(pos + Vector2(Hex.width/2,0))
			points.append(pos + Vector2(Hex.width/4,Hex.height/2))
			points.append(pos + Vector2(-Hex.width/4,Hex.height/2))
			points.append(pos + Vector2(-Hex.width/2,0))
			var polygon = PoolVector2Array(points)
			self.draw_polygon(polygon,PoolColorArray([Color(0.37,0.37,0.37,0.5)]))
