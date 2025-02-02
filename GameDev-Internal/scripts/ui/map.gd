extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_map") and global.current_scene != "TutorialOne":
		audio.play_sound("button_press")
		
		if is_visible():
			hide()
		else:
			show()
	
	$LocMarker.position = _get_marker_pos()


func _get_marker_pos():
	var locmarker_pos : Vector2
	var map_x = $Minimap.position.x
	var map_y = $Minimap.position.y
	
	match global.current_scene:  # Set location marker position
			"GreenOne" : locmarker_pos = Vector2(map_x - 20, map_y - 6)
			"GreenTwo" : locmarker_pos = Vector2(map_x - 10, map_y - 6)
			"GreenThree" : locmarker_pos = Vector2(map_x, map_y - 6)
			"GreenFour" : locmarker_pos = Vector2(map_x + 10, map_y - 6)
			"GreenFive" : locmarker_pos = Vector2(map_x + 20, map_y - 6)
			"GreenSix" : locmarker_pos = Vector2(map_x, map_y + 4)
			"GreenSeven" : locmarker_pos = Vector2(map_x + 10, map_y + 4)
	
	return locmarker_pos
