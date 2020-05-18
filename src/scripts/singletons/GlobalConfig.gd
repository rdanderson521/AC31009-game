extends Node

const biomes = {"grass":0,"grass_trees":1,"grass_forest":2,"grass_rocks":3,"grass_rocks_trees":4,"mountain":5,
	"rainforest":6,"snow":7,"snow_trees":8,"snow_forest":9,"snow_rocks":10,"snow_rocks_trees":11,
	"water_ice":12,"water":13,"desert":14,"desert_rocks":15,"desert_dunes":16,"desert_mountain":17,
	"desert_oasis":18}
	
const biome_moves = {0:1, 1:1, 2:2, 3:2, 4:3, 5:-1, 6:3, 7:1, 8:1, 9:2, 10:2, 11:3, 12:2, 13:1, 14:1, 15:2, 16:1 ,17:-1, 18:3}
const biome_resources = {0:{"food":2,"construction":1}, 1:{"food":1,"construction":2}, 
	2:{"food":3,"construction":2}, 3:{"food":1,"construction":2}, 4:{"food":2,"construction":3},
	5:{"food":0,"construction":0}, 6:{"food":3,"construction":3}, 7:{"food":2,"construction":1}, 
	8:{"food":1,"construction":2}, 9:{"food":3,"construction":2}, 10:{"food":1,"construction":2},
	11:{"food":2,"construction":3}, 12:{"food":2,"construction":0}, 13:{"food":2,"construction":0},
	14:{"food":2,"construction":1}, 15:{"food":1,"construction":2}, 16:{"food":2,"construction":1},
	17:{"food":0,"construction":0}, 18:{"food":3,"construction":1}}

const impasible_biomes = [5,17]
const water_biomes = [12,13]

var testing = true

var map: Dictionary
var map_size: Vector2

var special_resources: Dictionary
var special_resource_tiles: Dictionary

var unit_tiles: Dictionary
var building_tiles: Dictionary
var city_tiles: Dictionary

func _init():
	self.map = Dictionary()
	self.special_resource_tiles = Dictionary()
	self.unit_tiles = Dictionary()
	self.building_tiles = Dictionary()
	self.city_tiles = Dictionary()
	SignalManager.connect("kill_unit",self,"kill_unit")
	SignalManager.connect("kill_building",self,"kill_building")
	
func units_on(hex):
	var units = Array()
	if hex is Array:
		for i in hex:
			if self.unit_tiles.has(i):
				units.append(unit_tiles[i])
	elif hex is Vector2:
		if self.unit_tiles.has(hex):
				units.append(unit_tiles[hex])
	return units
	
func kill_unit(unit):
	self.unit_tiles.erase(unit.hex_pos)
	
func kill_building(building):
	self.building_tiles.erase(building.hex_pos)
	if building is City:
		self.city_tiles.erase(building.hex_pos)

