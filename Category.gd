extends Control

signal RequestTeam(category: Node)

var node = preload("res://team.tscn")

var callable = Callable(self, "FreeQueue")

var children = []

@export var label_name: String

func _ready():
	$CategoryName.text = label_name

func _on_add_team_pressed():
	RequestTeam.emit(self)

func add_team(name: String):
	var team = node.instantiate()
	team.text = name
	children.append(name)
	team.connect("FreeQueue", callable)
	$ScrollContainer/CategoryContainer.add_child(team)
	$ScrollContainer.size.y = $ScrollContainer.size.y + team.size.y
	custom_minimum_size.y = custom_minimum_size.y + team.size.y


func FreeQueue(size: int):
	$ScrollContainer.size.y = $ScrollContainer.size.y - size
	custom_minimum_size.y = custom_minimum_size.y - size


func _on_remove_category_pressed():
	queue_free()

func save():
	
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"name" : $CategoryName.text,
		"size_x" : 0,
		"size_y" : 40,
		"children" : children
	}
	return save_dict
