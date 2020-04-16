tool
extends Node2D


export(bool) var reset: bool = false setget onReset
export(int) var tileCount_x: int = 1
export(int) var tileCount_y: int = 1
export(Texture) var spritesheet: Texture

#config
var tileSize_x: int = 0
var tileSize_y: int = 0
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
				#var sb2d = StaticBody2D.new()
				#tile.add_child(sb2d)
				#sb2d.set_owner(self)
				#sb2d.position.y = 32
				
				#var collision = CollisionPolygon2D.new()
				#var collision_points = PoolVector2Array([Vector2(-32,-56),Vector2(32,-56),
				#Vector2(64,0),Vector2(32,56),Vector2(-32,56),Vector2(-64,0)])
				#sb2d.add_child(collision)
				#collision.set_owner(self)
				#collision.polygon = collision_points
				
				
				
				

