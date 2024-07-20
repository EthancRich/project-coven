class_name Cell extends Node2D
## Cell is the object that is contained in the grid.
## Cells hold a reference to their (x,y) grid unit position.
## Cells may contain a reference to an object in order
## to "contain" it, though currently objects in the grid
## like jobs and pipes are not children to their cell.

## index of the cell in the grid (x,y)
var index: Vector2i = Vector2i(-1,-1)

## Object that the cell contains (job, pipe)
var contained_object: Node2D = null


## Sets the currently contained object to passed object.
func set_contained_object(new_object: Node2D) -> void:
	contained_object = new_object


## Sets the currently contained object to null.
func remove_contained_object() -> void:
	contained_object = null


## Returns a reference to the current object contained.
func get_contained_object() -> Node:
	return contained_object
	
	
## Returns true if the contained object is a job, and
## false otherwise.
func contains_job() -> bool:
	if contained_object is Job:
		return true
	return false


## Returns true if the cell has a contained object, and
## false otherwise.
func is_occupied() -> bool:
	if contained_object != null:
		return true
	return false
