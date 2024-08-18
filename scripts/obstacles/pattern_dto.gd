extends Node

var points: Array
var next_point_index = 0

func reset_counter():
	next_point_index = 0

func has_more_points() -> bool:
	return next_point_index < points.size()

func get_next_point() -> Vector2:
	var index = next_point_index
	next_point_index += 1
	return points[index] as Vector2

