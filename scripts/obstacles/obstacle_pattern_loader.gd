extends Node

class_name Patterns

var pattern_list: Array
var island_locations: Array

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
	
	var islands_file = FileAccess.open("islands.json", FileAccess.READ)
	var cont = islands_file.get_as_text()
	var islands_json = JSON.parse_string(cont) as Array
	island_locations = []
	for item in islands_json:
		var x = item["x"]
		var y = item["y"]
		var vector = Vector2(x, y)
		island_locations.append(vector)

