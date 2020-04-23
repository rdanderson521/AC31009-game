extends Player

class_name AI

var state: int

const EXPLORE = 0
const BUILD = 1
const ATTACK = 2
const READY_ATTACK = 3

func _init(start_hex:Vector2).(start_hex,true):
	self.unit_vis_range = 5
	self.building_vis_range = 7
	self.state = EXPLORE
	pass
		
func turn_start():
	is_turn = true
	self.turn += 1
	
	units_attention_needed.clear()
	buildings_attention_needed.clear()
	
	if !units.empty():
		for i in self.units:
			if i.turn_start():
				units_attention_needed.push_back(i)
	
	if !buildings.empty():
		for i in self.buildings:
			if i.turn_start():
				buildings_attention_needed.push_back(i)
	self.turn_end()

func turn_end():
	if is_turn:
		is_turn = false
		selected_object = null
		SignalManager.player_turn_ended(self)
		
func building_decisions():
	for i in self.buildings_attention_needed:
		var building_resources = i.resources_per_turn
		

