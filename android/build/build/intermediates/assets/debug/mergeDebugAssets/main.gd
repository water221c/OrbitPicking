extends Node2D

var category_node = preload("res://category.tscn")

var inputted_team: String
var inputted_category: String
var emitting_category: Node

var callable = Callable(self, "_on_category_request_team")

func _ready():
	load_game()

func _on_category_request_team(category):
	$InsertTeam.show()
	emitting_category = category


func _on_team_confirm_button_pressed():
	if ($InsertTeam/TextEdit.text != ""):
		inputted_team = $InsertTeam/TextEdit.text
		$InsertTeam.hide()
		$InsertTeam/TextEdit.text = ""
		emitting_category.call("add_team", inputted_team)


func _on_team_cancel_button_pressed():
	$InsertTeam.hide()
	$InsertTeam/TextEdit.text = ""


func _on_category_confirm_button_pressed():
	if ($InsertCategory/TextEdit.text != ""):
		inputted_category = $InsertCategory/TextEdit.text
		$InsertCategory.hide()
		$InsertCategory/TextEdit.text = ""
		add_category(inputted_category)

func _on_category_cancel_button_pressed():
	$InsertCategory.hide()
	$InsertCategory/TextEdit.text = ""

func _on_category_button_pressed():
	$InsertCategory.show()

func add_category(name: String):
	var node = category_node.instantiate()
	node.label_name = name
	node.connect("RequestTeam", callable)
	$Background/ScrollContainer/CategoryContainer.add_child(node)


func _on_clear_pressed():
	for node in $Background/ScrollContainer/CategoryContainer.get_children():
		node.queue_free()


func _on_save_pressed():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	for category in $Background/ScrollContainer/CategoryContainer.get_children():
		
		if (category.scene_file_path.is_empty()):
			print("persistent node '%s' is not an instanced scene, skipped" % category.name)
			continue
			
		var category_data = category.save()
		
		var json_string = JSON.stringify(category_data)
		
		save_game.store_line(json_string)
		

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return
	
	for i in $Background/ScrollContainer/CategoryContainer.get_children():
		i.queue_free()
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if (parse_result != OK):
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var node_data = json.get_data()
		
		var new_object = load(node_data["filename"]).instantiate()
		new_object.label_name = node_data["name"]
		new_object.connect("RequestTeam", callable)
		get_node(node_data["parent"]).add_child(new_object)
		new_object.custom_minimum_size = Vector2(node_data["size_x"], node_data["size_y"])
		
		var children = node_data["children"]
		if (typeof(children) == TYPE_ARRAY):
			if (new_object.has_method("add_team")):
				for i in children.size():
					new_object.add_team(children[i])
