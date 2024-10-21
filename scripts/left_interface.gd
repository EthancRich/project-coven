class_name LeftInterface extends Control
## Left Interface script responds to the interface's
## requests for adding new potion orders.

## Reference variables
@onready var influence_val_label: Label = %InfluenceValLabel
@onready var influence_diff_label: Label = %InfluenceDiffLabel
@onready var recruit_button: Button = $PanelContainer/MarginContainer/VBoxContainer/TopPanel/RecruitButton
@onready var witch_images_1: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/TopPanel/VBoxContainer/WitchImages1
@onready var witch_images_2: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/TopPanel/VBoxContainer/WitchImages2

## Signals
signal recruit_hovered
signal recruit_pressed
signal recruit_unhovered


## Restarts the UI on the left side when the game restarts.
func restart() -> void:
	reveal_witch_image(2)
	recruit_button.disabled = false
	get_tree().call_group("order", "delete")


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
	influence_diff_label.text = str(" " + infl_diff)
	

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
	

## Turns the relevant witch icon visible
func reveal_witch_image(witch_num: int) -> void:
	
	hide_witch_images()
	
	if witch_num > 8:
		return
	
	if witch_num >= 5:
		witch_images_2.visible = true
	
	for i in range(witch_num):
		var index = i+1
		var witch_name := "WitchImage" + str(index)
		print(witch_name)
		var witch_image: TextureRect = null
		
		if index <= 4:
			witch_image = witch_images_1.get_node(witch_name) as TextureRect
		else:
			witch_image = witch_images_2.get_node(witch_name) as TextureRect
			
		if not witch_image:
			return
		
		witch_image.show()
	
	
func hide_witch_images() -> void:
	for witch_image: TextureRect in witch_images_1.get_children():
		witch_image.hide()
	for witch_image: TextureRect in witch_images_2.get_children():
		witch_image.hide()


## Disables the recruitment button.
func disable_recruit_button() -> void:
	recruit_button.disabled = true
	

## When the mouse enters the recruit button, have it send a signal to change the influence
func _on_recruit_button_mouse_entered() -> void:
	recruit_hovered.emit()


## When the mouse leaves the recruit button, have it send a signal to revert the influence change
func _on_recruit_button_mouse_exited() -> void:
	recruit_unhovered.emit()
	

## When the button is pressed
func _on_recruit_button_pressed() -> void:
	recruit_pressed.emit()
