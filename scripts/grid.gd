class_name Grid extends Node2D
## Grid is the underlying grid structure that is attached to the board.
## It dictates the size of the grid, as well as references to the cells
## it contains. The script has functions to interface with the cells using
## indexes and positions.

## The number of cells high
@export var grid_height: int = 20

## The number of cells long
@export var grid_width: int = 30

## TODO: Remove. For demo purposes. Contains a preloaded job for the grid.
@export var job_scene_1: PackedScene = preload("res://scenes/red_job.tscn")

## TODO: Remove. For demo purposes. Contains a preloaded job for the grid.
@export var job_scene_2: PackedScene = preload("res://scenes/blue_job.tscn")

## A 1D array of the cells in the grid. These are mapped from the 2D grid space.
## NOTE: The grid cells are translated top to bottom, then side to side.
var grid_reference: Array[Cell] = []


## Function called on creation. Initializes all the cells in the grid.
## TODO: Remove demo jobs.
func _ready() -> void:
	
	# preload the scene for cells
	var cell_scene: PackedScene = preload("res://scenes/cell.tscn")
	
	# Cells in grid range top to bottom, then left to right
	for x in range(grid_width):
		for y in range(grid_height):
			
			# Create the new cell and add to scene tree
			var new_cell: Cell = cell_scene.instantiate() as Cell
			var x_offset: int = 64 * x
			var y_offset: int = 64 * y
			new_cell.position = Vector2(x_offset, y_offset)
			new_cell.index = Vector2i(x,y)
			self.add_child(new_cell)
			
			# Place the cell reference into the grid_reference
			grid_reference.push_back(new_cell)
	
	# Create two jobs and put them on the grid for demo purposes
	create_job(0, Vector2i(1,0), 3)
	create_job(1, Vector2i(1,1), 5)
	
	
## Creates a single job and places it on the grid in a provided location.
## TODO: Update for general use; currently just for testing purposes.
## TODO: Namely, general jobs, and safety for locations.
func create_job(job_type: int, index2D: Vector2i, num_cells: int) -> void:
	
	# Populate variable with a PackedScene of the job being created
	var new_job: Job = null
	match job_type:
		0:	# Red Job
			new_job = job_scene_1.instantiate() as Job
		1:	# Blue Job
			new_job = job_scene_2.instantiate() as Job
		_:
			new_job = job_scene_1.instantiate() as Job
	
	# Set the job's placement in the grid to the location of the cell at given index
	new_job.position = grid_reference[index2D_to_1D(index2D)].position
	
	# Create an array of every cell the new job will be occupying. No safety checks :(
	var cell_array: Array[Cell] = []
	for i in range(num_cells):
		var cell = grid_reference[index2D_to_1D(Vector2i(index2D.x+i, index2D.y))]
		cell_array.push_back(cell)
		
	# Point the job to the cells, and each cell to the job
	new_job.current_cells = cell_array
	new_job.connect_current_cells()
	
	# Add to the scene tree
	self.add_child(new_job)
		

## Converts from an (x,y) in global pixels to (x,y) in grid units.
## NOTE: Grid units start at (0,0) in top left, then expand down and right.
## TODO: Potentially make the size of the cells variable, not fixed at 64.
func pixels_to_index(pixels: Vector2) -> Vector2i:
	if is_pixels_out_of_bounds(pixels):
		if Global.DEBUG_MODE:
			push_error(self.name, " [pixels_to_index]", " index out of bounds ", pixels)
		return Vector2i(-1, -1)
	@warning_ignore("narrowing_conversion")
	return Vector2i(pixels.x / 64, pixels.y / 64)
	
	
## Converts from an (x,y) in grid units to (x,y) in global pixels.
## NOTE: Grid units start at (0,0) in top left, then expand down and right.
## TODO: Potentially make the size of the cells variable, not fixed at 64.
func index_to_pixels(index: Vector2i) -> Vector2:
	if is_index_out_of_bounds(index):
		if Global.DEBUG_MODE:
			push_error(self.name, " [index_to_pixels]", " index out of bounds ", index)
		return Vector2(-32, -32)
	return Vector2(index.x * 64, index.y * 64)
	
	
## Converts from an (x,y) in grid units to a single value for internal
## grid reference array. Returns -1 if 2D index provided isn't within range.
func index2D_to_1D(index2D: Vector2i) -> int:
	if is_index_out_of_bounds(index2D):
		if Global.DEBUG_MODE:
			push_error(self.name, " [index2D_to_1D]", " index out of bounds ", index2D)
		return -1
	return grid_height * index2D.x + index2D.y
	
	
## Returns the cell in the grid at a given (x,y) location.
## If the provided index is out of bounds, then the function will return null.
func get_cell_at_index(index2D: Vector2i) -> Cell:
	var index1D: int = index2D_to_1D(index2D)
	if index1D < 0:
		if Global.DEBUG_MODE:
			push_error(self.name, " [get_cell_at_index]", " index out of bounds ", index2D)
		return null
	return grid_reference[index1D]


## Returns true if the provided (x,y) position in grid units is outside of the
## range of the grid, and false otherwise.
func is_index_out_of_bounds(index2D: Vector2i) -> bool:
	var is_out_of_bounds_row: bool = index2D.x < 0 or index2D.x >= grid_width
	var is_out_of_bounds_col: bool = index2D.y < 0 or index2D.y >= grid_height
	return is_out_of_bounds_row or is_out_of_bounds_col
	
	

## Returns true if the provided (x,y) position in pixels is outside of the
## range of the grid, and false otherwise.
func is_pixels_out_of_bounds(pixels2D: Vector2) -> bool:
	var is_out_of_bounds_row: bool = pixels2D.x < 0 or pixels2D.x >= grid_width * 64
	var is_out_of_bounds_col: bool = pixels2D.y < 0 or pixels2D.y >= grid_height * 64
	return is_out_of_bounds_row or is_out_of_bounds_col
