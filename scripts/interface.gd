class_name Interface extends CanvasLayer
## Interface script responds to Game script requests
## to add a new potion order, and passes it to the
## left interface.


## passes the order to the left interface to handle. 
func add_potion_order(new_order: OrderControl) -> void:
	($LeftInterface as LeftInterface).add_potion_order(new_order)
