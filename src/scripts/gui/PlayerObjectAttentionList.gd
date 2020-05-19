extends "res://scripts/gui/GuiPanel.gd"

var btn_list
var btn_container

var player

const btn = preload("res://scenes/gui/PlayerObjectAttentionButton.tscn")
const btn_sript = preload("res://scripts/gui/PlayerObjectAttentionButton.gd")


func _init():
	SignalManager.connect("turn_start_obj_attention_needed",self,"turn_start")
	SignalManager.connect("building_build_start",self,"object_moves_done")
	SignalManager.connect("moves_left_change",self,"moves_left_change")
	SignalManager.connect("new_building",self,"add_object")
	SignalManager.connect("new_unit",self,"add_object")

func _ready():
	self.btn_list = Array()
	self.btn_container = $ScrollContainer/VBoxContainer
	self.player = self.find_parent("Player*")

func turn_start(units,buildings):
	self.clear_buttons()
	self.visible = true
	for i in units:
		var new_btn = btn.instance()
		new_btn.set_script(btn_sript)
		new_btn.init(i)
		self.btn_list.append(new_btn)
		self.btn_container.add_child(new_btn)
		new_btn.visible = true
	for i in buildings:
		var new_btn = btn.instance()
		new_btn.set_script(btn_sript)
		new_btn.init(i)
		self.btn_list.append(new_btn)
		self.btn_container.add_child(new_btn)
		new_btn.visible = true
		
func add_object(obj,player):
	if player == self.player:
		var new_btn = btn.instance()
		new_btn.set_script(btn_sript)
		new_btn.init(obj)
		self.btn_list.append(new_btn)
		self.btn_container.add_child(new_btn)
		new_btn.visible = true
	
func clear_buttons():
	for i in self.btn_list:
		i.visible = false
		self.btn_container.remove_child(i)
		i.queue_free()
	self.btn_list.clear()

func object_moves_done(obj):
	for i in btn_list:
		if obj == i.obj:
			i.visible = false
			self.btn_list.erase(i)
			self.btn_container.remove_child(i)
			if self.btn_list.empty():
					self.visible = false
			i.queue_free()
			
func moves_left_change(unit,m):
	if m <= 0:
		for i in btn_list:
			if i.obj == unit:
				i.visible = false
				self.btn_container.remove_child(i)
				self.btn_list.erase(i)
				i.queue_free()
				if self.btn_list.empty():
					self.visible = false
				break
			
