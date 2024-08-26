class_name LeftInterface extends Control
## Left Interface script responds to the interface's
## requests for adding new potion orders.


## Adds the passed Order Control node to the container.
func add_potion_order(new_order: OrderControl) -> void:
	%OrderContainer.add_child(new_order)
