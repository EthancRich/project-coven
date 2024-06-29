class_name DefaultJob extends Job

signal dragging

var in_bounds: bool = false
var click_pressed_in_bounds: bool = false
var potential_new_cell: Cell = null
var current_cell: Cell
var retry_count: int = 0
var retry_cap: int = 3


func _ready():
	self.employee_max = 4
	self.employee_num = 0
	self.size = 1
	self.progress = 0
	self.current_cell = %Grid.get_children()[0]
	self.global_position = current_cell.global_position
	

func _process(delta):
	pass
	
func _input(event):
	if in_bounds:
		if event.is_action_pressed("click"):
			click_pressed_in_bounds = true
		elif event.is_action_released("click"):
			click_pressed_in_bounds = false

func move():
	Global.dragged_job = null
	
	var potential_new_cells = get_tree().get_nodes_in_group("mouse_in_bounds")
	var num_cells = potential_new_cells.size()
	print(potential_new_cells, num_cells)
	
	if num_cells == 0:
		print("No potential cell registered, exiting")
		retry_count = 0
		return
		
	elif num_cells > 1:
		print("more than 1 cell is registered, that's not good!")
		retry_count += 1
		await get_tree().create_timer(0.05).timeout
		if retry_count < retry_cap:
			move()
		else:
			print("retries failed, aborting job move")
			return
			
	elif potential_new_cells[0].is_in_group("occupied"):
		print("Cannot place here, the cell is occupied!")
		retry_count = 0
		return
		
	self.global_position = potential_new_cells[0].global_position
	current_cell = potential_new_cells[0]
	retry_count = 0


func _on_static_body_2d_mouse_entered():
	self.modulate.a = 0.8
	in_bounds = true


func _on_static_body_2d_mouse_exited():
	if click_pressed_in_bounds and Global.dragged_job == null:
		Global.dragged_job = self
		dragging.emit()
		click_pressed_in_bounds = false # Reset it so that it doesn't stay true
		
	self.modulate.a = 1.0
	in_bounds = false

		
