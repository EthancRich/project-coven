class_name StartPipeState extends State
## This state is entered if the player holds right click.
## A pipe can begin to be made if the player leaves the rightmost
## cell of a job to the right, where a pipe should exit.

## References to nodes to reduce overhead of additional calls.
@onready var board_node := %Board as Board
@onready var staging_node := %Staging as Node

## PackedScehe reference for the Pipe object
var pipe_scene: PackedScene = preload("res://scenes/pipe.tscn")

## Flag to prevent the on_signal functions to operate when not current state
var active_state = false

	
## Return to idle state if the right click is released
func update(_delta: float) -> void:
	if not board_node.is_right_click_down:
		transitioning.emit(self, "Idle")
	

## When cell transition occurs, check if moved to the right from a job
func _on_board_changed_mouse_cell(prev_cell_index: Vector2i, current_cell_index: Vector2i) -> void:
	
	if not active_state:
		return
	
	# Confirm that the player moved right
	var alt_index := Vector2i(prev_cell_index.x + 1, prev_cell_index.y)
	if alt_index != current_cell_index:
		return
		
	var prev_hovered_cell := board_node.get_prev_hovered_cell()
	if not prev_hovered_cell:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [_on_board_changed_mouse_cell]", " no previously hovered cell.")
		return
	
	var job := prev_hovered_cell.contained_object as Job
	if not job:
		return
	
	# Confirm that the player moved away from the rightmost cell of a job
	if prev_hovered_cell != job.current_cells.back():
		return
	
	# Confirm that the new cell isn't occupied
	var current_hovered_cell := board_node.get_current_hovered_cell()
	if current_hovered_cell.is_occupied():
		return

	# Create the new pipe parent object
	var new_pipe := pipe_scene.instantiate() as Pipe
	new_pipe.set_starting_job_cell(prev_hovered_cell)
	staging_node.add_child(new_pipe) # Pipe's position is at origin
	
	transitioning.emit(self, "Dropping Pipe")
	
	
## Update flag
func enter():
	active_state = true
	
	
## Update flag
func exit():
	active_state = false
