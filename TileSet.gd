tool
extends Node2D


export(bool) var reset = false setget onReset
export(int) var tileCount_x = 1
export(int) var tileCount_y = 1
export(Texture) var spritesheet

#config
var tileSize_x = 0
var tileSize_y = 0
#var spritesheet = preload("res://set_a.png")


func _ready():
	pass


func onReset(isTriggered):
	if(isTriggered):
		reset = false
		tileSize_x = spritesheet.get_width()/tileCount_x
		tileSize_y = spritesheet.get_height()/tileCount_y
		for y in range(tileCount_y):
			print("y:" + str(y))
			for x in range(tileCount_x):
				print("x:" + str(x))
				var id = x+y*tileCount_x
				var tile = Sprite.new()
				add_child(tile)
				tile.set_owner(self)
				tile.set_name(str(x+y*tileCount_x))
				tile.set_texture(spritesheet)
				tile.set_region(true)
				tile.set_region_rect(Rect2(x*tileSize_x, y*tileSize_y, tileSize_x, tileSize_y))
				tile.position = (Vector2(x*tileSize_x+tileSize_x/2, y*tileSize_y+tileSize_y/2))
				#new code
				var a2d = Area2D.new()
				tile.add_child(a2d)
				var collision = CollisionShape2D.new()
				a2d.add_child(collision)
				collision.shape = ConvexPolygonShape2D
				var collision_points = PoolVector2Array()
				collision_points.append([Vector2(-32,-56),Vector2(32,-56),
				Vector2(-64,0),Vector2(32,56),Vector2(-32,56),Vector2(-32,0)])
				collision.points = collision_points
				

