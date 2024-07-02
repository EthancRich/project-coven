class_name DefaultJob extends Job

signal dragging

#var in_bounds: bool = false
#var click_pressed_in_bounds: bool = false
# var potential_new_cell: Cell = null
var current_cell: Cell #TODO: Change to cells
# var retry_count: int = 0
# var retry_cap: int = 3


func _ready():
	self.employee_max = 4
	self.employee_num = 0
	self.size = 1
	self.progress = 0
	# self.current_cell = %Grid.get_children()[0]
	# self.global_position = current_cell.global_position
	

func _process(_delta):
	pass
	
func _input(event):
	pass
	#if in_bounds:
		#if event.is_action_pressed("click"):
			#click_pressed_in_bounds = true
		#elif event.is_action_released("click"):
			#click_pressed_in_bounds = false


func _on_static_body_2d_mouse_entered():
	self.modulate.a = 0.8
	#in_bounds = true


func _on_static_body_2d_mouse_exited():
	#if click_pressed_in_bounds and Global.dragged_job == null:
		#Global.dragged_job = self
		#dragging.emit()
		#click_pressed_in_bounds = false # Reset it so that it doesn't stay true
		
	self.modulate.a = 1.0
	#in_bounds = false

		
