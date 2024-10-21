extends CanvasLayer

@export var game_scene: PackedScene
@export var gui_scene: PackedScene
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
	#Remove witches first
	get_tree().call_group("restartable", "restart")	


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
