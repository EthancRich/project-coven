class_name DroppingDeadlineState extends State
## Dropping Deadline State script manages the board state
## When the player releases left click when holding a deadline
## The deadline placement is attempted, or aborted if the
## placement is invalid.

## Signals that the deadline couldn't be placed.
signal failed_deadline_drop


## The deadline logic begins upon entry.
## args == [deadline: Deadline]
func enter(args: Array) -> void:
	
	# Check to make sure a deadline object is provided
	if args.size() <= 0:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [enter]", " no Deadline object provided, aborting deadline drop.")
		transitioning.emit(self, "Idle")

	# Extract the object from args
	var current_deadline:= args[0] as Deadline
	
	# Check if current_deadline is null
	if not current_deadline:
		if Global.DEBUG_MODE:
			push_warning(self.name, " [enter]", " no Deadline object provided, defaulting to null")
		transitioning.emit(self, "Idle")
	
	if is_deadline_valid():
		current_deadline.is_set = true
	else:
		current_deadline.queue_free()
		failed_deadline_drop.emit()
	
	# Transition back to idle
	transitioning.emit(self, "Idle")
	
	
func is_deadline_valid() -> bool:
	return false
		# Decide if it's in a valid state or not
	# VALID:
		# To the right of the current timer
		# Influence is less than the cost of the deadline
