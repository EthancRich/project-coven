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

## Emitted when a witch tries to move but cannot because there is something to the right
signal landlocked


## Set the game node to listen for sound signals
func _ready() -> void:
	landlocked.connect(game_node._on_witch_landlocked)
	

## Handles inputs for the witch. This will add or remove
## the witch node from a job if it enters or leaves its vicinity.
func _input(event: InputEvent) -> void:
	
	# Witch is selected if clicked on the witch
	if event.is_action_pressed("click") and in_boundary:
		get_viewport().set_input_as_handled()
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
		if current_cell.contains_job():
			reparent(current_cell.contained_object)
		elif not (get_parent() is Board):
			reparent(board_node)
		

## Interpolates the location of the witch each frame.
func _physics_process(delta: float) -> void:
	if selected:
		global_position = global_position.lerp(get_global_mouse_position(), 20 * delta)
	elif rest_point is Vector2:
		global_position = global_position.lerp(rest_point, 10 * delta)
		

## returns true if, by removing a witch from the current job,
## the job would need to expand and could not expand.
func is_locked_by_job() -> bool:
	var job := get_parent() as Job
	if not job:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [is_locked_by_job]", " no job parent to current witch.")
		return false
		
	# if job can't expand and will attempt upon witch leaving
	if job.get_right_adjacent_cell() == null and job.will_job_expand():
		return true
	
	# Otherwise, not locked
	return false
		

## Updates state to mouse in bounds of witch.
func _on_area_2d_mouse_entered():
	in_boundary = true


## Updates state to mouse out of bounds of witch.
func _on_area_2d_mouse_exited():
	in_boundary = false
