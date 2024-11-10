extends CanvasLayer

var player_paused: bool = false


func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("pause"):
		
		# If the game is not currently paused, pause the game
		if not get_tree().paused:
			player_paused = true
			get_tree().paused = true
			show()
			return
			
		# Game is paused. Only bring down the pause menu if the player paused and not a game over
		if player_paused:
			player_paused = false
			get_tree().paused = false
			hide()


func _on_restart_button_pressed() -> void:
	get_tree().call_group("restartable", "restart")	
	get_tree().paused = false
	hide()


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
