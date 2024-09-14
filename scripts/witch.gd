class_name Witch extends Node2D
## Witch class describes the behavior of the workers.
## It is a drag and drop object that stores a pixel
## location for its current rest point.

## reference for board to reduce the overhead  of additional calls.
@onready var board_node := get_node("/root/Main/Game/Board") as Board
@onready var game_node := get_node("/root/Main/Game") as Game

## determines whether left click is being held on this witch or not
var selected: bool = false

## true if the mouse is inside the witch object, and false otherwise. 		
var in_boundary: bool = false

## the (x,y) pixel location of the witch's location. The witch
## lerps each frame to return to the rest point when it's
## defined, or stays still if it's null.
var rest_point: Variant = null

## Holds the last static location, in pixels, of the witch
var prev_position: Vector2 = Vector2(64,64)

## Emitted when a witch tries to move but cannot because there is something to the right
signal landlocked


## Set the game node to listen for sound signals
func _ready() -> void:
	landlocked.connect(game_node._on_witch_landlocked)
	prev_position = global_position
	print(prev_position)
	

## Handles inputs for the witch. This will add or remove
## the witch node from a job if it enters or leaves its vicinity.
func _input(event: InputEvent) -> void:
	
	# Witch is selected if clicked on the witch
	if event.is_action_pressed("click") and in_boundary:
		get_viewport().set_input_as_handled()
		prev_position = global_position
		print(prev_position)
		selected = true
	
	# Witch was released after a hold
	elif selected and event.is_action_released("click"):
		get_viewport().set_input_as_handled()
		selected = false
		
		# job landlocked on right and can't expand
		if is_locked_by_job(): 
			landlocked.emit()
			return
		
		var current_cell := board_node.get_current_hovered_cell()
		
		# If the current_cell is null, then witch is out of bounds and should be reset
		# FIXME: There's a better way to do this that doesn't lock up
		if not current_cell:
			if Global.DEBUG_MODE:
				push_warning(self.name, " [_input]", " cannot find hovered cell")
			rest_point = Vector2(32, 32)
			return
			
		# Reparent the witch to either board or job
		# TODO: Change where the witch is parented when not occupying a job
		var job := current_cell.contained_object as Job
		
		# If the job is a pickup box, have it sproing back to it's last position
		if job and job.is_pickup_job:
			rest_point = prev_position
			landlocked.emit() # For the sproing noise
		# If it's a job, then reparent it and let the job handle the rest point
		elif job:
			reparent(current_cell.contained_object)
		# If it is leaving a job to the board, reparent it and reset it's rest point
		elif not (get_parent() is Board):
			reparent(board_node)
		# Otherwise, just reset the rest point so the witch lands where the cursor drops it
		else:
			rest_point = null
		

## Interpolates the location of the witch each frame.
func _physics_process(delta: float) -> void:
	if selected:
		global_position = global_position.lerp(get_global_mouse_position(), 20 * delta)
	elif rest_point is Vector2:
		global_position = global_position.lerp(rest_point, 10 * delta)
	# if rest_point is null, then do not adjust global position
		

## returns true if, by removing a witch from the current job,
## the job would need to expand and could not expand.
func is_locked_by_job() -> bool:
	var job := get_parent() as Job
	if not job:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [is_locked_by_job]", " no job parent to current witch.")
		return false
		
	# If the object to the right is just a pipe, it's fine
	if job.get_right_adjacent_cell().contained_object is PipePiece:
		return false
	
	# if job can't expand and will attempt upon witch leaving
	if job.get_right_adjacent_cell().is_occupied() and job.will_job_expand():
		return true
	
	# Otherwise, not locked
	return false
		

## Updates state to mouse in bounds of witch.
func _on_area_2d_mouse_entered():
	in_boundary = true


## Updates state to mouse out of bounds of witch.
func _on_area_2d_mouse_exited():
	in_boundary = false
