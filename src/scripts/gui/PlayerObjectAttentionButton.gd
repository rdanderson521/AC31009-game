extends Button

var obj: GameObject

	
func init(obj):
	self.obj = obj
	$HBoxContainer/Icon.texture = load(obj.texture)
	print("button icon: ",obj.texture)
	if obj is Unit:
		$HBoxContainer/Text.text = obj.type + " has moves left"
	if obj is City:
		$HBoxContainer/Text.text = obj.type + " can start a build"

func _ready():
	self.connect("pressed",self,"pressed")
	
func pressed():
	SignalManager.select_object_btn(self.obj)

