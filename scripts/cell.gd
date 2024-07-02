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

#func _ready():
	#self.add_to_group("unoccupied")
#
#func occupy():
	#self.remove_from_group("unoccupied")
	#self.add_to_group("occupied")
	#
#func unoccupy():
	#self.remove_from_group("occupied")
	#self.add_to_group("unoccupied")
#
#
#func _on_area_2d_mouse_entered():
	#self.add_to_group("mouse_in_bounds")
#
#
#func _on_area_2d_mouse_exited():
	#self.remove_from_group("mouse_in_bounds")
#
#
#func _on_area_2d_body_entered(body):
	#occupy()
	#print("Calling 'occupy'")
#
#
#func _on_area_2d_body_exited(body):
	#unoccupy()
	#print("Calling 'unoccupy'")
