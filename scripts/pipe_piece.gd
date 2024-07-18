class_name PipePiece extends Node2D
## PipePiece is a single pipe portion to occupy a cell.
## It tracks a reference to the cell that contains it,
## as well as some additional functions that modify the
## piece.

## The cell that contains the pipe piece.
var current_cell: Cell


## Chooses an orientation for the pipe piece, then plays the
## according anitmation of the sprite.
## FIXME: This should use a different method instead of f, i indexes.
func initialize_orientation(index_f: Vector2i, index_i: Vector2i) -> void:
	var animatedSprite2D := $AnimatedSprite2D as AnimatedSprite2D
	var direction := indexes_to_direction(index_f, index_i)

	match direction:
		"right":
			animatedSprite2D.play("pipe1")
		"down":
			animatedSprite2D.play("pipe2")
		"up":
			animatedSprite2D.play("pipe2")
		_:
			animatedSprite2D.play("pipe1")
			if Global.DEBUG_MODE:
				push_warning(self.name, " [initialize_orientation] ", "Default case used.")


## Translates an initial and final (x,y) index position into a
## String that represents the movement in a direction.	
func indexes_to_direction(index_f: Vector2i, index_i: Vector2i) -> String:
	var diff := index_f - index_i
	if diff.x == 1:
		return "right"
	elif diff.y == 1:
		return "down"
	elif diff.y == -1:
		return "up"
	else:
		if Global.DEBUG_MODE:
			push_error(self.name, " [indexes_to_direction]", " Invalid difference: ", diff)
		return ""


## FIXME:This is the source of the bug, when it gets reparented.
func _on_tree_exiting():
	current_cell.remove_contained_object()
