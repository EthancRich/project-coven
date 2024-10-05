class_name OrderSetState extends State
## This is the state that the order is in if the player
## has set a deadline on this order.
## NOTE: Once in this state, the order doesn't leave.

## References
@onready var order: OrderControl = $"../.."
@onready var texture_progress_bar: TextureProgressBar = %TextureProgressBar


## Get rid of the timer visual once the deadline is set
func enter(_args: Array) -> void:
	texture_progress_bar.visible = false
	

## If the deadline is hit, then try to fulfill the order.
func update(_delta: float) -> void:
	if order.is_deadline_hit:
		if attempt_fulfill_order():
			order.connected_deadline.queue_free()
			order.queue_free()
	

## Try to complete the order by looking for pickup jobs with the desired potion
func attempt_fulfill_order() -> bool:
	
	# Get the pick up jobs on the board
	var pickup_jobs := get_tree().get_nodes_in_group("pickup")
	
	# Check if they have the right items
	for job: Job in pickup_jobs:
		if not job:
			continue
			
		for item: Item in job.input_items_array:
			if item.id == order.potion.id:
				fulfill_order(job, item)
				return true
	
	# If no item is found, return false
	return false


## Consume the potion produced, and emit signal for sound effects
func fulfill_order(job: Job, removal_item: Item) -> void:
	job.input_items_array.erase(removal_item)
	order.order_fulfilled.emit()
