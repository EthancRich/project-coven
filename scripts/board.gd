class_name Board extends Node2D

signal changed_mouse_cell

@export var longpress_time: float = 0.5
var current_mouse_position: Vector2
var prev_mouse_position: Vector2
var current_mouse_cell_index: Vector2i
var prev_mouse_cell_index: Vector2i
var is_click_down: bool = false
var grid_node: Grid = null
var focused_job_segment: int = -1


func _ready():
	grid_node = %Grid
	current_mouse_position = Vector2(0,0)
	prev_mouse_position = Vector2(0,0)
	current_mouse_cell_index = Vector2i(0,0)
	prev_mouse_cell_index = Vector2i(0,0)


func _process(delta):
	pass
	

func _unhandled_input(event):
	# If the player is moving their mouse, update mouse location
	if event is InputEventMouseMotion:
		prev_mouse_position = current_mouse_position
		current_mouse_position = get_global_mouse_position()
		prev_mouse_cell_index = current_mouse_cell_index
		current_mouse_cell_index = grid_node.pixelsToIndex(current_mouse_position)
		if prev_mouse_cell_index != current_mouse_cell_index:
			changed_mouse_cell.emit()

	# Otherwise, handle mouse clicks
	elif event.is_action_pressed("click"):
			is_click_down = true
			set_focused_object()
			
	elif event.is_action_released("click"):
			is_click_down = false
			
	elif event.is_action_pressed("increase"):
		get_tree().call_group("focused", "increase_size")
		
	elif event.is_action_pressed("decrease"):
		get_tree().call_group("focused", "decrease_size")
			
func get_current_hovered_cell():
	return grid_node.get_cell_at_index(current_mouse_cell_index)

func set_focused_object():
	# Get the new object to focus, and set its group
	remove_focused_object()
	var hovered_cell = get_current_hovered_cell()
	var focused_object = hovered_cell.get_contained_object()
	if focused_object != null:
		focused_object.add_to_group("focused")
	
	if focused_object is Job:
		focused_job_segment = focused_object.get_segment(hovered_cell.index)
	print("Focused object:", focused_object)
	if focused_job_segment != -1:
		print("Focused Job Segment:", focused_job_segment)
	
func remove_focused_object():
	var focused_objects = get_tree().get_nodes_in_group("focused")
	for object in focused_objects:
		object.remove_from_group("focused")
	focused_job_segment = -1
