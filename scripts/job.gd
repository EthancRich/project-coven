class_name Job extends Node2D

@export var size: int = 0
@export var employee_num: int = 0
@export var employee_max: int = 1
@export var progress: float = 0.0
var current_cells: Array[Cell]

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
	print(current_cells)
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
	
func _on_static_body_2d_mouse_entered():
	self.modulate.a = 0.8

func _on_static_body_2d_mouse_exited():
	self.modulate.a = 1.0
