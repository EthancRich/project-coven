class_name PipePiece extends Node2D
## PipePiece is a single pipe portion to occupy a cell.
## It tracks a reference to the cell that contains it,
## as well as some additional functions that modify the
## piece.

## The cell that contains the pipe piece.
var current_cell: Cell

## Flag to prevent losing pipe pointers upon reparenting.
var is_reparenting: bool = false

## Setting the pipe parent object
var pipe: Pipe


## Chooses an orientation for the pipe piece, then plays the
## according anitmation of the sprite.
## FIXME: This should use a different method instead of f, i indexes.
func initialize_orientation(current_index: Vector2i) -> void:
	var direction := indexes_to_direction(current_index)
	
	# Assign the correct animation depending on direction
	var animationString: String
	match direction:
		"right":
			animationString = "pipe1"
		"down":
			animationString = "pipe2"
		"up":
			animationString = "pipe2"
		_:
			animationString = "pipe1"
			if Global.DEBUG_MODE:
				push_warning(self.name, " [initialize_orientation] ", "Default case used.")
	
	# Update the sprite
	update_sprite(animationString)


## Updates the AnimatedSprite2D to the passed string.
func update_sprite(animation: String) -> void:
	($AnimatedSprite2D as AnimatedSprite2D).play(animation)


## Translates an initial and final (x,y) index position into a
## String that represents the movement in a direction.			
## NOTE: Potentially called before parent is Pipe
func indexes_to_direction(current_index: Vector2i) -> String:
	var prev_index := pipe.last_piece_index
	var diff := current_index - prev_index
	
	if diff.x == 1:
		return "right"
	elif diff.y == 1:
		return "down"
	elif diff.y == -1:
		return "up"
	else:
		if Global.DEBUG_MODE:
			push_error(self.name, " [indexes_to_direction]", " Invalid difference: ", diff)
		return ""


## Add the pipe piece to the pipe parent, if it exists
func add_piece_to_pipe() -> bool:
	
	# Check if the pipe object is empty
	if not pipe:
		if Global.DEBUG_MODE:
			push_error(self.name, " [try_add_piece_to_pipe]", " no pipe parent to attach to.")
		return false
	
	# Add the piece to the parent
	pipe.add_child(self)
	pipe.add_pipe_index(current_cell.index)
	pipe.update_pipe_sprites()
	return true
			
	
## Removes the cell's pointer to a pipe when the pipe is removed.
## NOTE: This also activates when it is reparented, so make sure to call
## reparent_pipe() instead to avoid this situation.
func _on_tree_exiting() -> void:
	if not is_reparenting:
		current_cell.remove_contained_object()


## Deletes the pipe and all pieces if any pipe piece is left clicked.
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("rclick"):
		pipe.queue_free()
		# TODO: Add any additional changes to the connections between jobs here
		# Create a pipe delete function that handles these things
