extends Node

class_name Patterns

var pattern_list: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open("points.json", FileAccess.READ)
	var contents = file.get_as_text()
	var json = JSON.parse_string(contents) as Array
	pattern_list = []
	for item in json:
		var points = item["points"]
		var obstacle_positions = []
		for point in points:
			var x = point["x"]
			var y = point["y"]
			var vector = Vector2(x, y)
			obstacle_positions.append(vector)
		pattern_list.append(obstacle_positions)
	

