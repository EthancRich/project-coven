extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	erase_cell(0, Vector2i(0,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
