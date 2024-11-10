class_name AudioManager extends Node
## AudioManager contains container nodes for the music and sounds of the game.


## Sets the audio volume when readied
func _ready() -> void:
	set_audio_volume(0)
	
	
## sets the music to a percentage from 0% to 100%, adjusting the dB of each audiostreamplayer
func set_audio_volume(db: float) -> void:
	print("Test")
	for player: AudioStreamPlayer in get_children():
		if player is AudioStreamPlayer:
			player.volume_db = db
	
	
## stop_all gets all AudioStreamPlayers for music and calls stop.
func stop_all() -> void:
	for child: AudioStreamPlayer in get_children():
		child.stop()


## play_audio searches for the correct AudioStreamPlayer and plays that node.
func play_audio(audio_name: String) -> void:
	var audio := get_node(audio_name)
	if audio is AudioStreamPlayer:
		audio.play()
	else:
		print("Could not find \"" + name + "\" in children nodes.")
