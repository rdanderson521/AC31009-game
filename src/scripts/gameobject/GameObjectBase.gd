extends Node2D

class_name GameObject

var type: String
var health_max: int
var attack: int
var attack_range: int
var defence: int
var texture: String setget set_texture
var health: float setget set_health
var selected: bool
var hex_pos: Vector2 setget set_hex_pos
var mode: int setget set_mode

func set_texture(texture):
	if texture != null:
		$Area2D/CollisionPolygon2D/Sprite.texture = load(texture)
	
func set_health(h):
	health = h
	SignalManager.health_change(self,h)
	
func set_hex_pos(h):
	hex_pos = h
	
func set_mode(m):
	mode = m

