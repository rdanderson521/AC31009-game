extends Node2D

var fog_of_war: Array
var visible_tiles: Array

func draw_fow(fow:Array):
	self.fog_of_war = fow
	update()
	
func draw_visible(v:Array):
	self.visible_tiles = v
	update()
	
func draw():
	print("draw")
	self.visible = true
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
