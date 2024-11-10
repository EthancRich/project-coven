extends PanelContainer


func _ready() -> void:
	get_tree().root.get_viewport().size_changed.connect(resize)	
	
func resize() -> void:
	print("resized!")
	anchor_left = 0
	anchor_right = 1
	anchor_bottom = 1
	anchor_top = 0
	print(anchors_preset)

