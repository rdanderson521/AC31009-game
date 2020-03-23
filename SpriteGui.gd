extends PanelContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Sprite_sprite_clicked(sprite):
	self.find_node("SpriteTexture").texture = sprite.find_node("Sprite").texture
	self.find_node("SpriteName").text = sprite.type
	self.find_node("SpriteMoves").text = str(sprite.move_range)
