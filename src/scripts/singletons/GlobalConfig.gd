extends Node

const biomes = {"grass":0,"grass_trees":1,"grass_forest":2,"grass_rocks":3,"grass_rocks_trees":4,"mountain":5,
	"rainforest":6,"snow":7,"snow_trees":8,"snow_forest":9,"snow_rocks":10,"snow_rocks_trees":11,
	"water_ice":12,"water":13,"desert":14,"desert_rocks":15,"desert_dunes":16,"desert_mountain":17,
	"desert_oasis":18,"fog":19,"fog_transparent":20}

const impasible_biomes = [5,17]
const water_biomes = [12,13]

var map: Dictionary
var map_size: Vector2

func _init():
	map = Dictionary()

