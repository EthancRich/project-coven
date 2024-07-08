class_name Witch extends Node2D

@onready var board_node = get_node("/root/Main/Board")
var selected = false
var in_boundary = false
var rest_point = null

func _input(event):
	if event.is_action_pressed("click") and in_boundary:
		get_viewport().set_input_as_handled()
		selected = true
		
	elif selected and event.is_action_released("click"):
		get_viewport().set_input_as_handled()
		selected = false
		# Assign this to the job that the witch is currently in, or the cell if it's not
		var current_cell:Cell = board_node.get_current_hovered_cell()
		# Do something depending on whether you're in job or not job
		if current_cell.contains_job():
			reparent(current_cell.contained_object)
		elif !(get_parent() is Board):
			reparent(board_node)
		

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 20 * delta)
	elif rest_point is Vector2:
		global_position = lerp(global_position, rest_point, 10 * delta)
		
func _on_area_2d_mouse_entered():
	in_boundary = true

func _on_area_2d_mouse_exited():
	in_boundary = false
