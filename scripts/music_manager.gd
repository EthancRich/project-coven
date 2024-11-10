extends Node

## Whether the player is in a good or bad state
var is_good := true
var is_progressing := false

var current_good_volume := -10.0
var current_drum_volume := -40.0
var current_bad_volume := -40.0

var max_volume := -10.0
var min_volume := -40.0

@onready var music_good_main: AudioStreamPlayer = $MusicGoodMain
@onready var music_good_bass_melody: AudioStreamPlayer = $MusicGoodBassMelody
@onready var music_good_drums_1: AudioStreamPlayer = $MusicGoodDrums1
@onready var music_good_drums_2: AudioStreamPlayer = $MusicGoodDrums2
@onready var music_bad_main: AudioStreamPlayer = $MusicBadMain
@onready var music_bad_drums_1: AudioStreamPlayer = $MusicBadDrums1
@onready var music_bad_drums_2: AudioStreamPlayer = $MusicBadDrums2

var left_interface: LeftInterface
var order_container: VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_good_main.volume_db = current_good_volume
	music_good_bass_melody.volume_db = current_good_volume
	music_good_drums_1.volume_db = current_drum_volume
	music_good_drums_2.volume_db = current_drum_volume
	music_bad_main.volume_db = current_bad_volume
	music_bad_drums_1.volume_db = current_bad_volume
	music_bad_drums_2.volume_db = current_bad_volume
	
	left_interface = $"../../Interface/LeftInterface" as LeftInterface
	order_container = left_interface.get_node("PanelContainer/MarginContainer/VBoxContainer/BottomPanel/ScrollContainer/OrderContainer")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if order_container.get_children().size() == 0:
		is_good = true
		is_progressing = false
	else:
		update_state_from_orders()
	
	if is_good:
		if current_good_volume < max_volume:
			# Increase good volume
			current_good_volume += 0.13
			music_good_main.volume_db = current_good_volume
			music_good_bass_melody.volume_db = current_good_volume
			
		if current_bad_volume > min_volume:
			# Decrease bad volume
			current_bad_volume -= 0.13
			music_bad_main.volume_db = current_bad_volume
			music_bad_drums_1.volume_db = current_bad_volume
			music_bad_drums_2.volume_db = current_bad_volume
			
		if is_progressing and current_drum_volume < max_volume:
			current_drum_volume += 0.13
			music_good_drums_1.volume_db = current_drum_volume
			music_good_drums_2.volume_db = current_drum_volume
			
		elif not is_progressing and current_drum_volume > min_volume:
			current_drum_volume -= 0.13
			music_good_drums_1.volume_db = current_drum_volume
			music_good_drums_2.volume_db = current_drum_volume
			
	else:
		if current_good_volume > min_volume:
			# Decrease good volume
			current_good_volume -= 0.1
			music_good_main.volume_db = current_good_volume
			music_good_bass_melody.volume_db = current_good_volume
			current_drum_volume -= 0.1
			music_good_drums_1.volume_db = current_drum_volume
			music_good_drums_2.volume_db = current_drum_volume
			
		if current_bad_volume < max_volume:
			# Increase bad volume
			current_bad_volume += 0.1
			music_bad_main.volume_db = current_bad_volume
			music_bad_drums_1.volume_db = current_bad_volume
			music_bad_drums_2.volume_db = current_bad_volume


func update_state_from_orders() -> void:
	is_progressing = true
	is_good = true
	
	for order: OrderControl in order_container.get_children():
		if not order:
			continue
			
		var text_label: Label = order.get_node("GridContainer/TextLabel") as Label
		if not text_label:
			continue
			
		if text_label.text == "Due":
			is_good = false
			break
			
		if text_label.text == " Set":
			is_progressing = false
