class_name LeftInterface extends Control
## Left Interface script responds to the interface's
## requests for adding new potion orders.

## Reference variables
@onready var influence_val_label: Label = %InfluenceValLabel
@onready var influence_diff_label: Label = %InfluenceDiffLabel


## Adds the passed Order Control node to the container.
func add_potion_order(new_order: OrderControl) -> void:
	%OrderContainer.add_child(new_order)


## Updates and manages the influence label information
func set_influence_labels(infl_val: String, infl_diff: String) -> void:
	
	# Await current node until it's ready to avoid null access
	if not influence_val_label:
		await self.ready
	
	# Update labels
	influence_val_label.text = infl_val
	influence_diff_label.text = infl_diff
	

## Play the gain or lose influence color change animation
func play_influence_label_animation(diff: int) -> void:
	
	# Await current node until it's ready to avoid null access
	if not influence_val_label:
		await self.ready
	
	var animation_player = influence_val_label.get_node("AnimationPlayer") as AnimationPlayer
	if diff < 0:
		animation_player.play("lose_influence")
	elif diff > 0:
		animation_player.play("gain_influence")
	
