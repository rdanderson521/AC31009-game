extends GameObject

class_name Building

#var is_city: bool
#var is_district: bool
var improvements: Dictionary
#var area: Array
#var resources_per_turn: Dictionary
var build_curr: String
var build_resources_left: Dictionary
var build_options: Dictionary
var build_options_outdated: bool

const DEFAULT = 0
const ATTACK = 3
const BUILD = 5

func _ready():
	pass
	
func set_hex_pos(h):
	hex_pos = h
	GlobalConfig.building_tiles[h] = self
	
func turn_start() -> bool:

	return false
	
func turn_end():
	pass

func can_build(building = null) -> bool:

	return false


		
func update_build_options():
	self.build_options.clear()
	
		
func kill():
	self.visible = false
	SignalManager.kill_building(self)
	self.queue_free()
			
