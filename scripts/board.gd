class_name Board extends Node2D
## Board contains information about the game board including
## the location of the mouse and tracks user inputs for selecting
## and moving jobs and pipes.

## Emitted when mouse moves across grid lines
signal changed_mouse_cell 

## Reference for nodes, minimizes access time
@onready var grid_node := %Grid as Grid
@onready var staging_node := %Staging as Node

## Amount of time before a press becomes a hold for dragging
@export var longpress_time: float = 0.1

## Current pixel location of the mouse after recent movement
var current_mouse_position := Vector2(0.0, 0.0)

## Previous pixel location of the mouse before recent movement
var prev_mouse_position := Vector2(0.0, 0.0)

## The (x,y) grid index corresponding to the current mouse location
var current_mouse_cell_index := Vector2i(0, 0)

## The (x,y) grid index corresponding to the previous mouse location
var prev_mouse_cell_index := Vector2i(0, 0)

## State variable tracking whether left click is down or up
var is_left_click_down: bool = false

## State variable tracking whether right click is down or up
var is_right_click_down: bool = false

## Global variable that tracks which cell of a job is selected
var focused_job_segment: int = -1


## _unhandled_input comes after each other input function that isn't handled.
## Updates states like mouse positions, mouse click states, and the currently
## focused object.
## TODO: Remove the increase / decrease functionality for jobs.
func _unhandled_input(event: InputEvent) -> void:
	
	# Motion occurred, then update positions and indexes
	if event is InputEventMouseMotion:
		prev_mouse_position = current_mouse_position
		current_mouse_position = get_global_mouse_position()
		prev_mouse_cell_index = current_mouse_cell_index
		current_mouse_cell_index = grid_node.pixels_to_index(current_mouse_position)
		if prev_mouse_cell_index != current_mouse_cell_index:
			emit_signal("changed_mouse_cell", prev_mouse_cell_index, current_mouse_cell_index)
	
	# Mouse clicks occurred, update the mouse state variables
	elif event is InputEventMouseButton:
		
		if event.is_action_pressed("click"):
				is_left_click_down = true
				set_focused_object()
				
		elif event.is_action_released("click"):
			is_left_click_down = false
			
		elif event.is_action_pressed("rclick"):
			is_right_click_down = true
			
		elif event.is_action_released("rclick"):
			is_right_click_down = false
	
	# Button presses occur, adjust the sizes of the jobs. TODO: Remove.
	elif event is InputEventKey:
		
		if event.is_action_pressed("increase"):
			get_tree().call_group("focused", "increase_size")
			
		elif event.is_action_pressed("decrease"):
			get_tree().call_group("focused", "decrease_size")
			

## Takes the current index and converts it to the cell in the grid.
## Returns null if there is no cell at the hovered index.
## TODO: Check each use of the function and check whether null case is handled.
func get_current_hovered_cell() -> Cell:
	return grid_node.get_cell_at_index(current_mouse_cell_index)
	

## Takes the previous index and converts it to the cell in the grid
## Returns null if there is no cell at the hovered index.
## TODO: Check each use of the function and check whether null case is handled.
func get_prev_hovered_cell() -> Cell:
	return grid_node.get_cell_at_index(prev_mouse_cell_index)


## Removes the current focused object and replaces it with the object
## in the cell that the mouse is currently hovering, as long as it isn't
## null. If the focus is a job, then obtain the segment as well.
## NOTE: Focused objects are tracked with a "focused" group tag, while
## segment is still tracked in Board.
func set_focused_object() -> void:
	
	# Remove all focused objects, sets segment to -1
	remove_focused_object()
	
	# Add the focused group tag to the object if it exists
	var hovered_cell: Cell = get_current_hovered_cell()
	if hovered_cell == null:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [set_focused_object]", " No hovered cell received.")
		return
		
	var focused_object := hovered_cell.get_contained_object()
	if focused_object == null:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [set_focused_object]", " No object in hovered cell.")
		return
		
	focused_object.add_to_group("focused")
	if Global.DEBUG_MODE:
		print(self.name, " [set_focused_object]", " Set ", focused_object, " as focused object.")
	
	# If the focused object is a Job, update its segment
	var focused_job := focused_object as Job
	if not focused_job:
		return
	focused_job_segment = focused_job.get_segment(hovered_cell.index)
	if Global.DEBUG_MODE:
		if focused_job_segment != -1:
			print(self.name, " [set_focused_object]", " Set ", focused_job_segment, " as focused segment.")
		else:
			push_error(self.name, " [set_focused_ojbect]", " Cannot find segment in Job. ", focused_job_segment)
	
	
## Removes all group tags from the currently focused objects. T he intent
## is that focused objects can only be focused one a time, but this is a
## failsafe to ensure that in the event of multiple, it resets.
func remove_focused_object() -> void:
	
	# Remove group tag "focused" from all nodes that have it
	var focused_objects := get_tree().get_nodes_in_group("focused")
	for object in focused_objects:
		object.remove_from_group("focused")
		
	# Reset segment
	focused_job_segment = -1


## adds the passed pipe to the "active_pipe" group tag
func set_active_pipe(pipe: Pipe) -> void:
	if remove_active_pipe() and Global.DEBUG_MODE:
		push_error(self.name, " [set_active_pipe]", " Removed additional pipe, should have already been removed.")
	pipe.add_to_group("active_pipe")
	

## Removes all objects from "active_pipe". Returns true if any
## objects have been removed.
func remove_active_pipe() -> bool:
	var did_remove := false
	var active_pipes := get_tree().get_nodes_in_group("active_pipe")
	for pipe in active_pipes:
		pipe.remove_from_group("active_pipe")
		did_remove = true
	return did_remove
	
