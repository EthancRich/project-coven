extends CanvasLayer

var is_paused: bool = false


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("pause"):
		if not is_paused:
			is_paused = true
			get_tree().paused = true
			show()
		else:
			is_paused = false
			get_tree().paused = false
			hide()
