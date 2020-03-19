extends Node2D

class Hex:

	const size = 16
	
	func _init():
		pass
	
	static func cube_to_axial(cube):
		var q = cube.x
		var r = cube.z
		return Vector2(q, r)
	
	static func axial_to_cube(hex):
		var x = hex.x
		var z = hex.y
		var y = -x-z
		return Vector3(x, y, z)
	
	static func point_to_hex(point):
		var q = ((2*point.x/3) / size )
		var r = (((-1*point.x/3) + (sqrt(3)* point.y/3)) / size )
		return cube_to_axial(hex_round(axial_to_cube(Vector2(q,r))))
		
	static func hex_to_point(hex):
		var x = ((3* hex.x )/2 ) * size
		var y = (((sqrt(3)* hex.x)/2) + (sqrt(3) * hex.y)) * size
		return Vector2(x, y)
		
	static func hex_round(cube):
		var rx = round(cube.x)
		var ry = round(cube.y)
		var rz = round(cube.z)
	
		var x_diff = rx - cube.x
		var y_diff = ry - cube.y
		var z_diff = rz - cube.z
	
		if x_diff > y_diff and x_diff > z_diff:
			rx = -ry-rz
		elif y_diff > z_diff:
			ry = -rx-rz
		else:
			rz = -rx-ry
	
		return Vector3(rx, ry, rz)
		
	static func hex_round_axial(hex):
		return cube_to_axial(hex_round(axial_to_cube(hex)))
