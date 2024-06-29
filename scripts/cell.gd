class_name Cell extends Node2D

func _ready():
	self.add_to_group("unoccupied")

func occupy():
	self.remove_from_group("unoccupied")
	self.add_to_group("occupied")
	
func unoccupy():
	self.remove_from_group("occupied")
	self.add_to_group("unoccupied")


func _on_area_2d_mouse_entered():
	self.add_to_group("mouse_in_bounds")


func _on_area_2d_mouse_exited():
	self.remove_from_group("mouse_in_bounds")


func _on_area_2d_body_entered(body):
	occupy()
	print("Calling 'occupy'")


func _on_area_2d_body_exited(body):
	unoccupy()
	print("Calling 'unoccupy'")
