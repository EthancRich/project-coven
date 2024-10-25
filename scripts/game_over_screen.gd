extends CanvasLayer

@export var game_over_text_color: Color
@export var game_won_text_color: Color

@onready var label: Label = $PanelContainer/VBoxContainer/Label
var game_node: Game

func _ready() -> void:
	game_node = get_parent().get_node("Game") as Game
	if not game_node:
		print("Couldn't bind Game Over Screen to Game Node!")
		
	game_node.game_ended.connect(_on_game_game_end)


func _on_game_game_end(game_state: int) -> void:
	
	# Adjust the game over screen to be a win or loss screen
	if game_state:
		label.text = "You Win!"
		label.add_theme_color_override("font_color", game_won_text_color)
	else:
		label.text = "Game Over"
		label.add_theme_color_override("font_color", game_over_text_color)
	
	# Stop all game functions by pausing the tree, and show the game over screen
	get_tree().paused = true
	show()


func _on_restart_button_pressed() -> void:
	get_tree().call_group("restartable", "restart")
	get_tree().paused = false
	hide()


func _on_quit_button_pressed() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
