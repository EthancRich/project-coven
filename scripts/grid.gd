extends Node2D


func _ready():
	var cell_scene = preload("res://scenes/cell.tscn")
	for x in 30:
		for y in 20:
			var new_cell = cell_scene.instantiate()
			var x_offset = 32 + 64 * x
			var y_offset = 32 + 64 * y
			new_cell.position = Vector2i(x_offset, y_offset)
			self.add_child(new_cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
