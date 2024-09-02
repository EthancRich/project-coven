class_name Job extends Node2D
## Job is a Node2D that represents a station or task
## on a gantt chart. They have multiple sizes (lengths),
## track the tasks' progress, and workers on the task.
## Job is in a one to many relationship with cells.


## The current size (length) of the job, in cells.
@export var size: int = 1

## The maximum size (length) of the job, in cells.
## NOTE: All jobs cannot exceed a max size of 5, as there
## is a static set of sprites to use for each size.
@export var max_size: int = 5

## The minimum size (length) of the job, in cells.
@export var min_size: int = 1

## The minimum number of workers required to be working on
## the job before the job can be worked on. Must be >=1.
## NOTE: More workers than the minimum cause the job to shrink.
@export var min_workers: int = 1

## The maximum number of workers on the job before the job
## cannot shrink further.
## NOTE: More workers can be added to the job, but the minimum
## size of the job will not be decreasd further.
## NOTE: Cannot exceed 4 as there is a static number of positions
## on the job's UI for the workers to sit.
## NOTE: If the value is 0, then overridden by auto_max_workers.
@export var max_workers: int = 0

## Suggested max worker count based on the scope of the job.
## NOTE: This value can be overridden by giving max_workers > 0.
@onready var auto_max_workers: int = min(4, min_workers + max_size - min_size)

## A percentage completion of the job, from 0 to 1.
@export var progress: float = 0.0

## Array containing references to all cells that job occupies.
var current_cells: Array[Cell]

## Array containing references to all witches occupying job.
var current_witches: Array[Witch]

## The leftmost(s) and rightmost pipes that may be connected to this job.
var source_pipes_array: Array[Pipe] = []
var dest_pipe: Pipe = null

## How quickly the progress bar's percentage changes each second.
var percent_per_second := 0.0

## Represents whether the job has finished.
var is_complete := false

## Signals emitted on growing or shrinking the job
signal job_grew
signal job_shrunk

## References to reduce repeated calls.
@onready var grid_node := get_node("/root/Main/Game/Board/Grid") as Grid
@onready var time_bar := get_node("/root/Main/Game/Board/TimeBar") as TimeBar
@onready var progress_bar := $ProgressBar as TextureProgressBar


## On creation, update the visual of the job when time bar is ready
func _ready() -> void:
	if time_bar:
		update_job_shape()
	else: 
		time_bar.ready.connect(update_job_shape) # Still having issues with this one


## Updates job progress if prereqs are met
func _process(delta: float) -> void:
	
	if is_complete:
		return
		
	# TODO: Switch this to require prereqs
	if current_witches.size() > 0:
		progress_bar.value += percent_per_second * delta
	
	# Complete the job if the bar is filled
	if not is_complete and progress_bar.value == 100:
		complete_job()


## Complete Job function updates the state of the job and 
## updates the visual sprites that indicate a completed task.
func complete_job() -> void:
	is_complete = true
	($CompleteColorRect as ColorRect).visible = true
	progress_bar.visible = false
	

## Pushes provided cell to the back of the current_cells array.
## TODO: Convert this process to a signal-based process where
## the cell reciprocates the reference in job both ways.
func add_current_cell(cell: Cell) -> void:
	current_cells.push_back(cell)
	
	
## Empties the cell references completely.
## TODO: See add_current_cell.
func remove_current_cells() -> void:
	current_cells.clear()


## Searches through each of the cells in the array, and sets
## their contained object to this job.
## TODO: See add_current_cell.
func connect_current_cells() -> void:
	for cell in current_cells:
		cell.set_contained_object(self)


## Searches through each of the cells in the array, and
## removes their contained object.
## TODO: See add_current_cell.
func disconnect_current_cells() -> void:
	for cell in current_cells:
		cell.remove_contained_object()


## Prints the cell array for the sake of debugging.
## TODO: Remove in final release.
func print_cells():
	print(current_cells)
	
	
## Returns the integer representing which of the job's
## cells is occupied by the given (x,y) position.
## 0 is the leftmost job cell, followed by 1, etc.
## Returns -1 if no segment is found.
func get_segment(index2D: Vector2i) -> int:
	
	## Obtain all markers for each segment of the job
	var markers := $SegmentMarkers.get_children()
	
	## Return if a marker has the same index as the index provided
	for i in range(size):
		var marker := markers[i] as Marker2D
		var marker_index := grid_node.pixels_to_index(marker.global_position)
		if marker_index == index2D:
			return i
		elif Global.DEBUG_MODE and marker_index == Vector2i(-1, -1):
			push_warning(self.name, " [get_segment]", " Segment position out of bounds. ", marker.global_position)
	
	## Return -1 if a segment doesn't resolve to an index
	if Global.DEBUG_MODE:
		push_error(self.name, " [get_segment]", " No segment found at ", index2D, ".")
	return -1
	
	
## Job will update it's sprite and collision based on the current size.
## NOTE: Depends on the 64px cell definition, will have to change if that changes.
func update_job_shape() -> void:
	
	# Play the new animation
	var animationName: String = "1x" + str(size)
	($AnimatedSprite2D as AnimatedSprite2D).play(animationName)
	
	# Update the size and offset of the collision square
	var collisionObj := $StaticBody2D/CollisionShape2D as CollisionShape2D
	collisionObj.position.x = 32 * size
	collisionObj.scale.x = 3 * size
	
	# Update the size of the progress bar and progress rate
	progress_bar.size.x = size * 64
	percent_per_second = 100.0 * time_bar.pixels_per_second / (size * 64)
	
	# Update the size of the complete sprite
	($CompleteColorRect as ColorRect).size.x = size * 64
	
	
## Causes a job to expand to the right a single cell. The function will
## connect the references between the job and new cell, then update the
## sprite for the job.
func increase_size() -> void:
	
	# Check that the current size is allowed to grow
	if size == max_size:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [increase_size]", " Current size is max size, cannot increase. ", size)
		return
		
	# Check that the next cell over is valid to expand
	var new_cell := get_right_adjacent_cell()
	if new_cell == null: # Warnings provided by get_right_additional_cell
		return
	
	# Update the references, size, and visuals.
	new_cell.set_contained_object(self)
	current_cells.push_back(new_cell)
	self.size = size + 1
	update_job_shape()
	job_grew.emit()
	
	
## Returns the cell that occupies the space directly to the right
## of the job if it's empty, and null otherwise.
func get_right_adjacent_cell() -> Cell:
	
	# Get the rightmost cell being occupied by the job
	var rightmost_cell := current_cells.back() as Cell
	if not rightmost_cell:
		if Global.DEBUG_MODE:
			push_error(self.name, " [get_right_adjacent_cell]", " current job has no cell references.")
		return null
		
	# Generate the index of the next cell over
	var new_index := Vector2i(rightmost_cell.index.x + 1, rightmost_cell.index.y)
	if grid_node.is_index_out_of_bounds(new_index):
		if Global.DEBUG_MODE:
			push_warning(self.name, " [get_right_adjacent_cell]", " right adjacent cell is out of bounds.")
		return null
		
	# Check if the adjacent cell is occupied
	var adjacent_cell := grid_node.get_cell_at_index(new_index)
	if adjacent_cell.is_occupied():
		if Global.DEBUG_MODE:
			push_warning(self.name, " [get_right_adjacent_cell]", " right adjacent cell is occupied.")
		return null
		
	# Return the valid cell value
	return adjacent_cell
	
	
## Causes the job to reduce in size by a single cell to the left.
## This function updates the references in the removed cell,
## updates the size, and updates the visuals.
func decrease_size() -> void:
	
	# Check to see if the size is minimized already
	if size == min_size:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [decrease_size]", " Current size is min size, cannot decrease. ", size)
		return
	
	# Get the rightmost cell occupied by the current job
	var rightmost_cell := current_cells.back() as Cell
	if not rightmost_cell:
		if Global.DEBUG_MODE:
			push_error(self.name, " [get_right_adjacent_cell]", " current job has no cell references.")
		return
		
	# Update the references, size, and visuals.
	rightmost_cell.remove_contained_object()
	current_cells.pop_back()
	self.size = size - 1
	update_job_shape()
	job_shrunk.emit()


## Adds new child witches to a location and updates the size of the job.
func _on_child_entered_tree(node: Node) -> void:
	if node is Witch:
		var witch_node := node as Witch
		current_witches.push_back(witch_node)
		assign_witch_location(witch_node)
		update_job_size("entered")


## Removes the witch from references, updates the remaining witches
## locations, and then updates the size of the job.
func _on_child_exiting_tree(node: Node) -> void:
	if node is Witch:
		var witch_node := node as Witch
		current_witches.pop_at(current_witches.find(witch_node))
		remove_witch_location(witch_node)
		update_witch_locations()
		update_job_size("exiting")


## Assigns the provided witch with a rest location dependent on the
## index of the witch in the reference array.
## FIXME: Possible issue with returning on null location while the
## witch remains added to the job's reference array.
func assign_witch_location(witch_node: Witch) -> void:
	
	# Construct a path string to the correct marker
	var location_path: String = "WitchMarkers/Marker" + str(current_witches.find(witch_node))
	
	# Obtain the marker2D object at that path
	var location_marker := get_node(location_path) as Marker2D
	if not location_marker:
		if Global.DEBUG_MODE:
			push_error(self.name, " [assign_witch_location] ", " no Marker2D found for ", location_path)
		return
	
	# Set the rest point of the witch to that location
	witch_node.rest_point = location_marker.global_position	
	

## Sets the rest point of the witch to null, causing it not to seek any location.
func remove_witch_location(witch_node: Witch) -> void:
	witch_node.rest_point = null
	
	
## Reassigns each witch's location based on the new indexes in witch reference array.
func update_witch_locations() -> void:
	for witch in current_witches:
		assign_witch_location(witch)


## Changes the size of the job based on the current number of witches
## and whether a witch was just added or just removed.
## NOTE: state_string is either "entered" or "exiting".
func update_job_size(state_string: String) -> void:
	var witch_count := current_witches.size()
	
	if state_string.to_lower() == "entered":
		if max_workers > 0: # Override max
			if witch_count > min_workers and witch_count <= max_workers:
				decrease_size()
		else:				# Auto max
			if witch_count > min_workers and witch_count <= auto_max_workers:
				decrease_size()
				
	elif state_string.to_lower() == "exiting":
		if max_workers > 0:	# Override max
			if witch_count >= min_workers and witch_count < max_workers:
				increase_size()
		else:				# Auto max
			if witch_count >= min_workers and witch_count < auto_max_workers:
				increase_size()
		

## Runs a simulated decrease in witch count to determine whether the job
## will increase to accomodate, or simply stay the same.
func will_job_expand() -> bool:
	var adjusted_witch_count := current_witches.size() - 1
	
	if max_workers > 0:	# Override max
		if adjusted_witch_count >= min_workers and adjusted_witch_count < max_workers:
			return true
	else:				# Auto max
		if adjusted_witch_count >= min_workers and adjusted_witch_count < auto_max_workers:
			return true
			
	return false


## Causes the opacity of the job to decrease when mouse is inside
func _on_static_body_2d_mouse_entered() -> void:
	self.modulate.a = 0.8


## Causes the opacity of the job to increase when the mouse is outside
func _on_static_body_2d_mouse_exited() -> void:
	self.modulate.a = 1.0
