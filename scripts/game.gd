class_name Game extends Node
## Game script carries out the overarching gameplay
## Coordination and tracking tasks that are
## board and static agnostic.

## Preloads and References
var potion_order_scene = preload("res://scenes/order_control.tscn")


## Create orders to start
## TODO: Automate this process
func _ready() -> void:
	create_order(0)
	create_order(0)


## Instantiate a new order, and pass it to the UI to add
func create_order(potion_enum: int) -> void:
	var new_order := potion_order_scene.instantiate() as OrderControl
	new_order.set_potion_type(potion_enum)
	($"../Interface" as Interface).add_potion_order(new_order)






