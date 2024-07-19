class_name ContinuePipeState extends State
## ContinuePipeState is a limbo state that branches into many pipe states.
## It waits until a movement occurs, and depending on the movement,
## It will transition to creating or removing pipe pieces.

## board node reference to reduce overhead on repeated calls.
@onready var board_node := %Board as Board

## grid node reference to reduce overhead on repeated calls.
@onready var grid_node := %Grid as Grid

## staging node reference to reduce overhead on repeated calls.
@onready var staging_node := %Staging as Node

## True if the current state is ContinuePipeState, false otherwise.
var active_state = false


## Set active_state
func enter() -> void:
	active_state = true


## Set active_state
func exit() -> void:
	active_state = false
	
	
## check each frame to see if the right click is released
func update(_delta: float) -> void:
	if !board_node.is_right_click_down:
		transitioning.emit(self, "Abandoning Pipe")


## Decides the next state to transition
## TODO: Consider whether the prev and current cell indexes are necessary
func _on_board_changed_mouse_cell(_prev_cell_index: Vector2i, current_cell_index: Vector2i) -> void:

	# Quit if this was triggered in a different state
	print(_prev_cell_index, " ", current_cell_index)
	if !active_state:
		return
	
	var pipe := get_active_pipe()
	if not pipe:
		if Global.DEBUG_MODE:
			push_error(self.name, " [_on_board_changed_mouse_cell]", " No pipe object to work with.")
		return
	
	# If the most recent pipe piece is where the user is hovering
	# NOTE: This effectively eliminates the first call where
	# moving into the first pipe cell counts the call
	if pipe.last_piece_index == current_cell_index:
		return
	
	# Eliminate any movements that aren't to legal moves
	var possible_locations := pipe.get_possible_cell_indexes()
	if !(current_cell_index in possible_locations):
		if Global.DEBUG_MODE:
			print(self.name, " [_on_board_changed_mouse_cell]", current_cell_index, " not in ", possible_locations)
		return
		
	# At this point, the player is hovering over N/E/S/W of last pipe piece
	# Option 1: The player moved back to their previous cell
	if pipe.get_pprev_index() == current_cell_index:
		if Global.DEBUG_MODE:
			print(self.name, " [_on_board_changed_mouse_cell] ", "Moved into original cell.")
		transitioning.emit(self, "Erasing Pipe")
		return
	
	# If the player is going left, then don't allow it
	if current_cell_index == possible_locations[0]:
		if Global.DEBUG_MODE:
			print(self.name, " [_on_board_changed_mouse_cell] ", "Moved into west cell, blocked.")
		return
		
	# Player at this point has moved N/E/S by 1 
	# Option 2: The player moved into a new job to end the pipe
	var current_cell := grid_node.get_cell_at_index(current_cell_index)
	if not current_cell:
		if Global.DEBUG_MODE:
			push_error(self.name, " [_on_board_changed_mouse_cell] ", "Current cell null.")
		return
		
	if current_cell.contains_job():
		var hovered_job := current_cell.contained_object as Job
		if hovered_job.current_cells[0] == current_cell:
			if Global.DEBUG_MODE:
				print(self.name, " [_on_board_changed_mouse_cell] ", "Entered viable end spot.")
			transitioning.emit(self, "Ending Pipe")
			return
	
	# Option 3: The player has moved into unoccupied square to drop pipe piece
	if !current_cell.is_occupied():
		transitioning.emit(self, "Dropping Pipe")
	
	
## Returns the pipe object that is currently being populated
## NOTE: Assumes active pipe is the first Pipe child in Staging
func get_active_pipe() -> Pipe:
	for child in staging_node.get_children():
		if child is Pipe:
			return child as Pipe
	return null
