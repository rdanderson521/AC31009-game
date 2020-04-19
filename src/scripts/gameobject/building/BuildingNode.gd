extends GameObject

class_name Building

var is_city: bool
var is_district: bool
var improvements: Dictionary
var area: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	self.get_parent().area += self.area
	print(self.get_parent())
	#update()


func _draw():
	print("draw")
	if is_city:
		print("draw city")
		
		for i in self.area:
			var points = Array()
			var pos = Hex.hex_to_point(i)
			points.append(pos + Vector2(-Hex.width/4,-Hex.height/2)-self.position)
			points.append(pos + Vector2(Hex.width/4,-Hex.height/2)-self.position)
			points.append(pos + Vector2(Hex.width/2,0)-self.position)
			points.append(pos + Vector2(Hex.width/4,Hex.height/2)-self.position)
			points.append(pos + Vector2(-Hex.width/4,Hex.height/2)-self.position)
			points.append(pos + Vector2(-Hex.width/2,0)-self.position)
			var polygon = PoolVector2Array(points)
			draw_polygon(polygon,PoolColorArray([self.get_parent().colour]))
			
	
