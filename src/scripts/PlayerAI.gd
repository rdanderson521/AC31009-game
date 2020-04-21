extends Player

class_name AI

func _init(start_hex:Vector2).(start_hex,true):
	pass
	
func _ready():
	
	self.fow = GlobalConfig.map.keys()
	var start_area_hex = Hex.hex_in_range(4,self.start_hex)
	start_area_hex.append(self.start_hex)
	for i in start_area_hex:
		fow.erase(i)
		
func turn_start():
	is_turn = true
	self.turn += 1
		
	if !units.empty():
		for i in self.units:
			#print("unit:" + str(i))
			if i.turn_start():
				units_attention_needed.push_back(i)
	self.turn_end()
			
func turn_end():
	if is_turn:
		is_turn = false
		selected_object = null
		SignalManager.player_turn_ended(self)
