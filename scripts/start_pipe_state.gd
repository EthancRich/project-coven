class_name StartPipeState extends State

@onready var board_node: Board = %Board
@onready var staging_node: Node = %Staging
var pipe_scene: PackedScene = preload("res://scenes/pipe.tscn")
var active_state = false

func enter():
	active_state = true
	
func exit():
	active_state = false
	
func update(_delta: float):
	if !board_node.is_right_click_down:
		transitioning.emit(self, "Idle")

func _on_board_changed_mouse_cell(prev_cell_index, current_cell_index):
	if !active_state:
		return
	var prev_hovered_cell = board_node.get_prev_hovered_cell()
	## FIXME: Null check here
	if !prev_hovered_cell.contains_job():
		return
	var job: Job = prev_hovered_cell.contained_object
	if prev_hovered_cell != job.current_cells.back():
		return
	# At this point, the player moved away from the rightmost space of a job
	var moved_right = current_cell_index.x - prev_cell_index.x > 0
	var moved_vertical = current_cell_index.y - prev_cell_index.y != 0
	if moved_vertical or !moved_right:
		return
	# At this point, the player moved right
	var current_hovered_cell = board_node.get_current_hovered_cell()
	print("Moving into cell:", current_hovered_cell, current_hovered_cell.contained_object)
	if current_hovered_cell.is_occupied():
		print("START PIPE: Item Occupied. Aborting")
		return
	# At this point, the cell moved into is empty
	print("Moving into empty cell!")
	
	# Create the new pipe parent object
	var new_pipe = pipe_scene.instantiate()
	new_pipe.set_starting_job_cell(prev_hovered_cell)
	staging_node.add_child(new_pipe) # Pipe's position is at origin
	
	transitioning.emit(self, "Dropping Pipe")
	
