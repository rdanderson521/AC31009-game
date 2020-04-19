extends GameObject

class_name Building

var is_city: bool
var is_district: bool
var improvements: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	update()


func _draw():
	print("draw")
	if is_city:
		print("draw city")
		var area = Hex.hex_in_range(1,self.hex_pos)
		area.append(self.hex_pos)
		for i in area:
			var points = Array()
			var pos = Hex.hex_to_point(i)
			points.append((pos + Vector2(-Hex.width/4,-Hex.height/2)))
			points.append(pos + Vector2(Hex.width/4,-Hex.height/2))
			points.append(pos + Vector2(Hex.width/2,0))
			points.append(pos + Vector2(Hex.width/4,Hex.height/2))
			points.append(pos + Vector2(-Hex.width/4,Hex.height/2))
			points.append(pos + Vector2(-Hex.width/2,0))
			var polygon = PoolVector2Array(points)
			draw_polygon(polygon,PoolColorArray([self.get_parent().colour]))
			
	
