class_name PipePiece extends Node2D

var current_cell: Cell

func initialize_orientation(index_f: Vector2i, index_i: Vector2i):
	var animatedSprite2D = $AnimatedSprite2D
	var direction = indexes_to_direction(index_f, index_i)
	if direction == null:
		print("INITIALIZE_ORIENTATION: No such direction")
		return
	match direction:
		"right":
			animatedSprite2D.play("pipe1")
		"down":
			animatedSprite2D.play("pipe2")
		"up":
			animatedSprite2D.play("pipe2")
	print("Done!")
		
func indexes_to_direction(index_f: Vector2i, index_i: Vector2i):
	var diff = index_f - index_i
	if diff.x == 1:
		return "right"
	elif diff.y == 1:
		return "down"
	elif diff.y == -1:
		return "up"
	else:
		print("INDEXES_TO_DIRECTION: Invalid difference:", diff)

func _on_tree_exiting():
	current_cell.remove_contained_object()
