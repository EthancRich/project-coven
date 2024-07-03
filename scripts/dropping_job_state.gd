class_name DroppingJobState extends State

func enter():
	var hovered_cell = %Board.get_current_hovered_cell()
	if is_legal_drop(hovered_cell):
		move(%Board.focused_object, hovered_cell)
	%Board.remove_focused_object() #TODO: Set to a signal for Board to modify
	transitioning.emit(self, "Idle")
	
func exit():
	pass

func is_legal_drop(hovered_cell: Cell):
	if !(hovered_cell is Cell):
		print("Cannot Drop: Cannot find cell being hovered over")
		return false
	if hovered_cell.is_occupied():
		print("Cannot Drop: Hovered cell is occupied")
		return false
	if !(%Board.focused_object is Job):
		print("Cannot Drop: Focused Object isn't Job (may be null?)")
		return false
	return true
	
func move(job: Job, new_cell: Cell):	
	if new_cell == null:
		print("Cannot move: new cell is null!")
		return
	job.global_position = %Grid.indexToPixels(new_cell.index)
	job.current_cell.remove_contained_object()
	new_cell.set_contained_object(job)
	job.current_cell = new_cell
