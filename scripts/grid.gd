class_name Grid extends Node2D

@export var grid_height = 20
@export var grid_width = 30 
var grid_reference: Array = []

func _ready():
	# preload the scene for cells
	var cell_scene = preload("res://scenes/cell.tscn")
	var default_job_scene = preload("res://scenes/default_job.tscn")
	
	# Populate the grid_reference with cell references,
	for x in grid_width:
		for y in grid_height:
			
			# Create the new cell and add to scene tree
			var new_cell = cell_scene.instantiate()
			var x_offset = 32 + 64 * x
			var y_offset = 32 + 64 * y
			new_cell.position = Vector2i(x_offset, y_offset)
			new_cell.index = Vector2i(x,y)
			self.add_child(new_cell)
			
			# Place the cell reference into the grid_reference
			grid_reference.push_back(new_cell)
	
	# Create a single job and place it in the first cell
	var first_cell = grid_reference[0]
	var new_job = default_job_scene.instantiate()
	
	new_job.position = first_cell.position
	new_job.current_cell = first_cell
	first_cell.set_contained_object(new_job)
	self.add_child(new_job)
	

func _process(delta):
	pass


func pixelsToIndex(pixels: Vector2i):
	return Vector2i(pixels.x / 64, pixels.y / 64)
	
	
func indexToPixels(index: Vector2i):
	return Vector2i(index.x * 64 + 32, index.y * 64 + 32)
	
	
func index2Dto1D(index2D: Vector2i):
	var index1D = grid_height * index2D.x + index2D.y
	if index1D < 0 or index1D > grid_height * grid_width:
		print("index2Dto1D: index out of bounds")
		return
	return index1D
	
	
func get_cell_at_index(index2D: Vector2i):
	return grid_reference[index2Dto1D(index2D)]
