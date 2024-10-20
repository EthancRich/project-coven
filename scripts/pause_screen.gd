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




func _on_restart_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
