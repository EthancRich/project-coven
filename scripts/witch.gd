class_name Witch extends Node2D

## Instance Variables
@onready var board_node: Board = get_node("/root/Main/Board")
var selected: bool = false 		# If Witch is left-clicked currently
var in_boundary: bool = false	# If mouse is in witch sprite boundary
var rest_point: Variant = null	# Vector2i pixel location to reside

func _input(event) -> void:
	if event.is_action_pressed("click") and in_boundary:
		get_viewport().set_input_as_handled()
		selected = true
		
	elif selected and event.is_action_released("click"):
		get_viewport().set_input_as_handled()
		selected = false
		
		if is_locked_by_job(): # job landlocked on right and can't expand
			return
			
		var current_cell := board_node.get_current_hovered_cell()
		if current_cell.contains_job():
			reparent(current_cell.contained_object)
		elif !(get_parent() is Board):
			reparent(board_node)
		

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 20 * delta)
	elif rest_point is Vector2:
		global_position = lerp(global_position, rest_point, 10 * delta)
		
		
func is_locked_by_job():
	var parent = get_parent()
	if !(parent is Job):
		return false
	else:
		var job: Job = parent
		# if job can't expand and will attempt upon witch leaving
		if job.get_right_adjacent_cell() == null and job.will_job_expand():
			return true
	return false
		
		
func _on_area_2d_mouse_entered():
	in_boundary = true

func _on_area_2d_mouse_exited():
	in_boundary = false
