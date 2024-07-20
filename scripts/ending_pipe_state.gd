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
		get_active_pipe().reparent(grid_node)
		transitioning.emit(self, "Idle")


## Check to see if the player has exited a valid end state, then transition.
func _on_board_changed_mouse_cell(_prev_cell_index: Vector2i, current_cell_index: Vector2i) -> void:
	if not active_state:
		return
		
	# Check for regressing backwards to go back to the last states
	var pipe := get_active_pipe()
	var possible_locations := pipe.get_possible_cell_indexes()
	if not (current_cell_index in possible_locations):
		return
	# At this point, the player is hovering over N/E/S/W of last pipe piece
	
	# The player moved back to their previous cell
	if pipe.get_pprev_index() == current_cell_index:
		if Global.DEBUG_MODE:
			print(self.name, " [_on_board_changed_mouse_cell]", " Returned to previous cell.")
		transitioning.emit(self, "Erasing Pipe")


## Obtains the active pipe, or returns null if there isn't one.
## TODO: Convert this into a group tag thing instead to be easier to obtain
func get_active_pipe() -> Pipe:
	for child in staging_node.get_children():
		if child is Pipe:
			return child as Pipe
	return null
			

## Sets active state.
func enter() -> void:
	active_state = true


## Sets active state.
func exit() -> void:
	active_state = false
