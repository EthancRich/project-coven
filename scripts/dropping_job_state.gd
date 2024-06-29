class_name DroppingJobState extends State

func enter():
	print("Entering Dropping Job State")
	Global.dragged_job.move()	
	transitioning.emit(self, "Idle")
	
func exit():
	print("Exiting Dropping Job State")
	

