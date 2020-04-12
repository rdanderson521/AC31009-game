extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false


func _on_Sprite_sprite_clicked(sprite):
	print("spriteClicked")
	self.find_node("SpriteTexture").texture = sprite.find_node("Sprite").texture
	self.find_node("SpriteName").text = sprite.type
	self.find_node("SpriteMoves").text = str(sprite.move_range)
	self.visible = true


func _on_Sprite_is_selected(val):
	self.visible = val
