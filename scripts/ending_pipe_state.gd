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

## Signal for pipe sounds
signal pipe_dropped


## Each frame, check to complete the pipe.
func update(_delta: float) -> void:
	if not board_node.is_right_click_down:
		
		# Obtain the pipe object
		var pipe := get_tree().get_first_node_in_group("active_pipe") as Pipe
		
		# Complete the pipe by pointing each job to the pipe
		pipe.source_job.dest_pipe = pipe
		pipe.dest_job.source_pipes_array.push_back(pipe)
		
		# Reparent the pipe from the stage to the board
		pipe.reparent_pipe(grid_node)
		board_node.remove_active_pipe()
		
		transitioning.emit(self, "Idle")
		pipe_dropped.emit()
		pipe.source_job.try_deliver_output()


## Check to see if the player has exited a valid end state, then transition.
func _on_board_changed_mouse_cell(_prev_cell_index: Vector2i, current_cell_index: Vector2i) -> void:
	if not active_state:
		return
	
	var pipe := get_tree().get_first_node_in_group("active_pipe") as Pipe
	if current_cell_index in pipe.pipe_indexes and current_cell_index != pipe.last_piece_index:
		if Global.DEBUG_MODE:
			print(self.name, " [_on_board_changed_mouse_cell]", " Returned to editing pipe.")
		
		# Remove the destination job in the pipe pointer
		pipe.dest_job = null
		transitioning.emit(self, "Erasing Pipe", [current_cell_index])
	

## Sets active state.
func enter(_args: Array) -> void:
	active_state = true


## Sets active state.
func exit() -> void:
	active_state = false
