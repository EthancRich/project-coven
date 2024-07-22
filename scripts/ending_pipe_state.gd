class_name EndingPipeState extends State
## This state represents the valid completion of a pipe.
## Once the right click is lifted, the pipe will complete.
## If the player moves back into old pipe cell, it will re-engage
## The earlier states.

## References to reduce the overhead of additional calls.
@onready var board_node: Board = %Board
@onready var grid_node: Grid = %Grid
@onready var staging_node: Node = %Staging

## Stops the signal function to be called when not current state.
var active_state = false


## Each frame, check to complete the pipe.
func update(_delta: float) -> void:
	if not board_node.is_right_click_down:
		# Move the pipe from staging into grid
		var pipe := get_tree().get_first_node_in_group("active_pipe") as Pipe
		pipe.reparent_pipe(grid_node)
		board_node.remove_active_pipe()
		transitioning.emit(self, "Idle")


## Check to see if the player has exited a valid end state, then transition.
func _on_board_changed_mouse_cell(_prev_cell_index: Vector2i, current_cell_index: Vector2i) -> void:
	if not active_state:
		return
		
	# Check for regressing backwards to go back to the last states
	var pipe := get_tree().get_first_node_in_group("active_pipe") as Pipe
	var possible_locations := pipe.get_possible_cell_indexes()
	if not (current_cell_index in possible_locations):
		return
	# At this point, the player is hovering over N/E/S/W of last pipe piece
	
	# The player moved back to their previous cell
	# FIXME: This caused an error that crashed the game when it's job, single cell, job, moving from end to front
	if pipe.get_pprev_index() == current_cell_index:
		if Global.DEBUG_MODE:
			print(self.name, " [_on_board_changed_mouse_cell]", " Returned to previous cell.")
		transitioning.emit(self, "Erasing Pipe", [current_cell_index])
		
	#if pipe.get_pprev_index() == current_cell_index: # This kinda requires the first cell of the job to be included
		##var cell := grid_node.get_cell_at_index(current_cell_index)
		##var pipe_piece := cell.contained_object as PipePiece
		##pipe_piece.delete_marker = true # Set the marker to delete up to that point
		#if Global.DEBUG_MODE:
			#print(self.name, " [_on_board_changed_mouse_cell]", " Returned to previous cell.")
		#transitioning.emit(self, "Continuing Pipe")
			

## Sets active state.
func enter(_args: Array) -> void:
	active_state = true


## Sets active state.
func exit() -> void:
	active_state = false
