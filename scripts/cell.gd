class_name Cell extends Node2D

# index of the cell in the grid (x,y)
var index: Vector2i = Vector2i(-1,-1)
var contained_object = null

func set_contained_object(new_object):
	contained_object = new_object
	
func remove_contained_object():
	contained_object = null

func get_contained_object():
	return contained_object
	
func contains_job():
	if contained_object is Job:
		return true
	return false
	
func is_occupied():
	if contained_object != null:
		return true
	return false
