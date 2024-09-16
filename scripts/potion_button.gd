class_name PotionButton extends TextureButton
## Potion Button script emits a signal when the button
## is dragged out of while pressed, so that the game
## can create a new deadline for that order.

## References
@onready var board_node := get_node("/root/Main/Game/Board") as Board

## Fires when mouse leaves button while held.
## Represents a new deadline needing to be instantiated.
signal create_new_deadline

## Tracks whether the button is pressed down or not.
## For some reason, the internal var isn't tracking right.
@warning_ignore("shadowed_variable_base_class")
var is_pressed := false

## Stops repeated signals from being sent while a deadline
## has been created but not assigned.
var is_deadline_created := false


## Sets is_pressed according to the button state.
func _on_button_down() -> void:
	is_pressed = true


## Sets is_pressed according to the button state.
func _on_button_up() -> void:
	is_pressed = false
	## This release event gets consumed in this function, so we have to set this here
	board_node.is_left_click_down = false
	

## Emits signal that the player intends to create a deadline.dda
func _on_mouse_exited() -> void:
	if not is_deadline_created and is_pressed:
		is_deadline_created = true
		create_new_deadline.emit()
