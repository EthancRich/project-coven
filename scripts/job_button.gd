extends TextureButton
## Job Button script emits a signal when the button
## is dragged out of while pressed, so that the game
## can create a new job that this button represents.


## Fires when mouse leaves button while held.
## Represents a new job needing to be instantiated.
signal create_new_job

## The job associated with this button
@export var job: PackedScene = preload("res://scenes/red_job.tscn")

## Whether the button is currently pressed or not.
@warning_ignore("shadowed_variable_base_class")
var is_pressed := false


## Updates the is_pressed state.
func _on_button_down() -> void:
	is_pressed = true


## Updates the is_pressed state.
func _on_button_up() -> void:
	is_pressed = false


## Fires the signal if the button is pressed and mouse leaves.
func _on_mouse_exited() -> void:
	if is_pressed:
		create_new_job.emit(job)
