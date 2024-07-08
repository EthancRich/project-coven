class_name Job extends Node2D

@export var size: int = 1
@export var max_size: int = 1
@export var min_size: int = 1
@export var min_workers: int = 1
@export var max_workers: int = 0
@onready var auto_max_workers: int = min(4, min_workers + max_size - min_size)
@export var progress: float = 0.0
var current_cells: Array[Cell]
var witch_count = 0

func add_current_cell(cell: Cell):
	current_cells.push_back(cell)
	
func remove_current_cells():
	current_cells.clear()

func connect_current_cells():
	for cell in current_cells:
		cell.set_contained_object(self)
	
func disconnect_current_cells():
	for cell in current_cells:
		cell.remove_contained_object()
	
func print_cells():
	print(current_cells)
	
func get_segment(index2D: Vector2i):
	var grid_node = get_parent()
	var markers = $SegmentMarkers.get_children()
	print(markers.size())
	for i in range(size):
		var marker = markers[i]
		var marker_index = grid_node.pixelsToIndex(marker.global_position)
		print("Marker", i, "Index:", marker_index, marker.global_position)
		if marker_index == index2D:
			return i
	print("Couldn't find any segment with given index")
	return -1
	
func update_job_shape():
	# Play the new animation
	var animationName = "1x" + str(size)
	$AnimatedSprite2D.play(animationName)
	# Update the size and offset of the collision square
	var collisionObj = $StaticBody2D/CollisionShape2D
	collisionObj.position.x = 32 * size
	collisionObj.scale.x = 3 * size
	
func increase_size():
	if size == max_size:
		print("INCREASE_SIZE: Size already maxed")
		return
	
	var grid_node = get_parent()
	
	# check whether the expanding cells are occupied
	var rightmost_item = current_cells.back()	
	if rightmost_item == null:
		print("INCREASE_SIZE: Job is not occupying any cells, returning")
		return
		
	var rightmost_cell: Cell = rightmost_item
	var new_index = Vector2i(rightmost_cell.index.x + 1, rightmost_cell.index.y)
	if grid_node.is_out_of_bounds(new_index):
		print("INCREASE_SIZE: Cell to expand to is out of bounds, returning")
		return
		
	var new_cell = grid_node.get_cell_at_index(new_index)
	if new_cell.is_occupied():
		print("INCREASE_SIZE: Cell is expand to is occupied, returning")
		return
		
	# update the new cell to contain the current job
	new_cell.set_contained_object(self)
	current_cells.push_back(new_cell)
	self.size = size + 1
	update_job_shape()
	
	
func decrease_size():
	if size == min_size:
		print("DECREASE_SIZE: Size already minimized")
		return

	# check whether the expanding cells are occupied
	var rightmost_item = current_cells.back()	
	if rightmost_item == null:
		print("INCREASE_SIZE: Job is not occupying any cells, returning")
		return
		
	var rightmost_cell: Cell = rightmost_item
	rightmost_cell.remove_contained_object()
	current_cells.pop_back()
	self.size = size - 1
	update_job_shape()


func assign_witch_location(witch_node: Witch):
	var location_path: String = "WitchMarkers/Marker" + str(witch_count - 1)
	witch_node.rest_point = get_node(location_path).global_position
	
func remove_witch_location(witch_node: Witch):
	witch_node.rest_point = null
	
func update_witch_locations():
	for child in get_children():
		if child is Witch:
			assign_witch_location(child)

func _on_static_body_2d_mouse_entered():
	self.modulate.a = 0.8

func _on_static_body_2d_mouse_exited():
	self.modulate.a = 1.0

func _on_child_entered_tree(node):
	if node is Witch:
		var witch_node: Witch = node
		witch_count += 1
		assign_witch_location(witch_node)
		if max_workers > 0: # Override max
			if witch_count > min_workers and witch_count <= max_workers:
				decrease_size()
		else:				# Auto max
			if witch_count > min_workers and witch_count <= auto_max_workers:
				decrease_size()

func _on_child_exiting_tree(node):
	if node is Witch:
		var witch_node: Witch = node
		witch_count -= 1
		remove_witch_location(witch_node)
		if max_workers > 0:	# Override max
			if witch_count >= min_workers and witch_count < max_workers:
				increase_size()
		else:				# Auto max
			if witch_count >= min_workers and witch_count < auto_max_workers:
				increase_size()
