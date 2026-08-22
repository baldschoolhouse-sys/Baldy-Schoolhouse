extends Node2D

var action = 0
var nodeMidiPlayer

#func _ready() -> void:
#	nodeMidiPlayer = get_node("MidiPlayer")
#	#nodeMidiPlayer.file = ""
#	nodeMidiPlayer.playing = true
#	print(nodeMidiPlayer.playing)

func _on_midi_player_midi_event(_channel: Variant, _event: Variant) -> void:
	pass # Replace with function body.
